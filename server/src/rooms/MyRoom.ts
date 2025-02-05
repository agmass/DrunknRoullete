import { Room, Client } from "@colyseus/core";
import { Entity, MyRoomState, NetPlayer } from "./schema/MyRoomState";

export class MyRoom extends Room<MyRoomState> {
  maxClients = 11;

  onCreate (options: any) {
    this.setState(new MyRoomState());

    let prev = Date.now();
    this.setSimulationInterval(()=>{
      let elapsed = (Date.now()-prev);

      prev = Date.now();
      this.state.globalTimer += elapsed;
    });

    this.onMessage("setState", (client, message) => {
      if (this.state.hostId==client.sessionId) {
        this.state.currentState = message.state;
      }
    });
    this.onMessage("shootBullet", (client, message) => {
      if (this.state.hostId==client.sessionId) {
         this.broadcast("shootBullet", {
          key: message.key, 
          x: message.x,
          y: message.y,
          angle: message.angle
        });
      }
    });
    this.onMessage("enemyPos", (client, message) => {
      if (this.state.hostId==client.sessionId) {
        if (this.state.networkedSprites.has(message.id)) {
          this.state.networkedSprites.get(message.id).x = message.x;
          this.state.networkedSprites.get(message.id).y = message.y;
          this.state.networkedSprites.get(message.id).angle = message.angle;
          this.state.networkedSprites.get(message.id).health = message.health;
        }
      }
    });
    this.onMessage("addEnemy", (client, message) => {
      if (this.state.hostId==client.sessionId) {
        let ent = new Entity();
        ent.entityClass = message.entityClass;
        ent.x = 0;
        ent.y = 0;
        ent.health = 100;
        if (message.entityGroup != undefined)
          ent.targetGroup = message.entityGroup;
        this.state.networkedSprites.set(message.id, ent);
      }
    });
    this.onMessage("refreshFile", (client, message) => {
      if (this.state.hostId==client.sessionId) {
        this.broadcast("refreshFile", {
          roomsTraveled: message.roomsTraveled,
          combo: message.combo,
          cheatedThisRun: message.cheatedThisRun,
          brokeWindow: message.brokeWindow,
          nextBoss: message.nextBoss,
          players: message.players,
        });
      }
    });
    this.onMessage("addInput", (client, message) => {
      const player = new NetPlayer();
      this.state.players.set(client.sessionId + "___" + message, player);
    });
    this.onMessage("requestSeedChange", (client, message)=> {
      if (this.state.hostId==client.sessionId) {
        setTimeout(() => {
          if (this.state != null)
            this.state.seed = Math.round(Math.random()*2147435376);
        }, 300);
      }
    })
    this.onMessage("openSubState", (client, message)=> {
      if (this.state.hostId==client.sessionId) {
        console.log(message.state)
        console.log(message.playerId)
        this.broadcast("openSubState", {state: message.state, playerId: message.playerId})
      }
    })
    this.onMessage("inputUpdate", (client, message) => {
      const player = this.state.players.get(client.sessionId + "___" + message.inputID);
      player.jumpPressed = message.jumpPressed;
      player.dashPressed = message.dashPressed;
      player.backslotPressed = message.backslotPressed;
      player.attackPressed = message.attackPressed;
      player.ui_denyPressed = message.ui_denyPressed;
      player.ui_menuPressed = message.ui_menuPressed;
      player.ui_acceptPressed = message.ui_acceptPressed;
      player.interactPressed = message.interactPressed;
      player.altFirePressed = message.altFirePressed;

      player.movement_x = message.movement_x;
      player.movement_y = message.movement_y;

      player.angle = message.angle;
      player.x = message.x;
      player.y = message.y;
      player.lastTimestamp = message.timestamp;
      player.randomAtLastTimestamp = message.randomTimestamp;
    
    });
  }

  onJoin (client: Client, options: any) {
    if (this.state.hostId == "") this.state.hostId = client.sessionId;
    this.state.inseed = Math.round(Math.random()*999999999999);
    console.log(client.sessionId, "joined!");
  }

  onLeave (client: Client, consented: boolean) {
    if (this.state.hostId == client.sessionId) {
      this.disconnect();
    }
    console.log(client.sessionId, "left!");
  }

  onDispose() {
    console.log("room", this.roomId, "disposing...");
  }

}
