package dge.backend.instance;
//just a simple class to swapping between layout

import dge.obj.mobile.VirtualButton;

class ButtonSwapHandle {
    public var arrayList(default, set):Array<Array<VirtualButton>> = [];//you cn change here but not recommend, just use addButton and removeButton
    public var curList(default, set):Int = -1;
    public var callBack:Int->Void;

    public function new() {
    }
    public function init(?callback:Int->Void) {
        this.callBack = callback;
        curList = 0;
    }

    public function addButton(button:VirtualButton, layout:Int = 0) {
        if (arrayList == null) {
            arrayList = [];
        }
        if (layout > arrayList.length) {
            layout = arrayList.length;
        }
        if (arrayList[layout] == null) {
            arrayList[layout] = [];
        }
        arrayList[layout].push(button);
        button.visible = layout == curList;
        button.disableInput = layout != curList;
    }

    public function removeButton(button:VirtualButton) {
        for (array in arrayList) {
            if (array != null) {
                for (i in 0...array.length) {
                    if (array[i] == button) {
                        array.splice(i, 1);
                        return;
                    }
                }
            }
        }
    }

    public function removeLayout(layout:Int) {
        if (layout < 0) layout = 0;
        if (layout > arrayList.length) layout = arrayList.length -1;
        if (arrayList != null && arrayList[layout] != null) {
            arrayList.splice(layout, 1);
        }
    }

    public function swapLayout(layout:Int) {
        curList = layout;
    }

    public function changeLayout(value:Int) {
        curList += value;
    }

    public function getAllButtons():Array<VirtualButton> {
        var out:Array<VirtualButton> = [];
        for (array in arrayList) {
            if (array != null) {
                for (button in array) {
                    out.push(button);
                }
            }
        }
        return out;
    }
    
    private function set_arrayList(value:Array<Array<VirtualButton>>):Array<Array<VirtualButton>> {
        arrayList = value;
        curList = 0;
        return value;
    }

    private function set_curList(value:Int):Int {
        if (curList != value) {
            if (arrayList != null && arrayList.length > 0) {
                if (value < 0) {
                    value = arrayList.length - 1;
                }
                if (value >= arrayList.length) {
                    value = 0;
                }
                curList = value;
                for (list in arrayList) {
                    for (button in list) {
                        button.visible = false;
                        button.disableInput = true;
                    }
                }
                for (button in arrayList[curList]) {
                    button.visible = true;
                    button.disableInput = false;
                }
                if (callBack != null) {
                    callBack(value);
                }
            } else {
                curList = 0;
            }
        }
        return value;
    }
}