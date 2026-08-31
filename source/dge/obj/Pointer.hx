package dge.obj;



class Pointer {
    public var x(default, set):Float = 0;
    public var y(default, set):Float = 0;
    public var onChange:Float->Float->Void;

    public function new(x:Float = 0, y:Float = 0) {
        this.x = x;
        this.y = y;
    }

    private function set_x(v:Float):Float {
        if (v != x) {
            x = v;
            if (onChange != null) onChange(x, y);
        } 
        return v;
    }
    private function set_y(v:Float):Float {
        if (v != y) {
            y = v;
            if (onChange != null) onChange(x, y);
        } 
        return v;
    }
}