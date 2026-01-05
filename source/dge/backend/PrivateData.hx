package dge.backend;
class PrivateData {
    private var stepCount:Int;
    private var beatCount:Int;
    private var sectionCount:Int;

    public function new() {
        stepCount = -1;
        beatCount = -1;
        sectionCount = -1;
    }
    //lmao
    public function get_stepCount():Int {
        return stepCount;
    }
    public function get_beatCount():Int {
        return beatCount;
    }
    public function get_sectionCount():Int {
        return sectionCount;
    }
    public function add_stepCount(value:Int = 1):Void {
        stepCount += value;
    }
    public function add_beatCount(value:Int = 1):Void {
        beatCount += value;
    }
    public function add_sectionCount(value:Int = 1):Void {
        sectionCount += value;
    }
    public function set_stepCount(value:Int = -1):Void {
        stepCount = value;
    }
    public function set_beatCount(value:Int = -1):Void {
        beatCount = value;
    }
    public function set_sectionCount(value:Int = -1):Void {
        sectionCount = value;
    }
}