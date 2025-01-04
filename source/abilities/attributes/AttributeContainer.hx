package abilities.attributes;

class AttributeContainer {
    public var operation:AttributeOperation;
    public var amount = 0.0;

    public function new(operation:AttributeOperation, amount:Float) {
        this.operation = operation;
        this.amount = amount;
    }
}