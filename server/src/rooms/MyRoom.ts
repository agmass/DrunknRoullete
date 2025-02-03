import { Room, Client } from "@colyseus/core";
import { MyRoomState, NetPlayer } from "./schema/MyRoomState";

export class MyRoom extends Room<MyRoomState> {
  maxClients = 11;

  onCreate (options: any) {
    this.setState(new MyRoomState());

    this.onMessage("addInput", (client, message) => {
      const player = new NetPlayer();
      this.state.players.set(client.sessionId + "___" + message, player);
    });
    this.onMessage("openSubState", (client, message)=> {
      if (this.state.hostId==client.sessionId) {
        console.log(message.state)
        console.log(message.playerId)
        this.broadcast("openSubState", {state: message.state, playerId: message.playerId})
      }
    })
    this.setSimulationInterval(()=>{
      this.state.seed = Math.round(Math.random()*2147435376);
    },500);
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
