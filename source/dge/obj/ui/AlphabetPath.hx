package dge.obj.ui;

class AlphabetPath extends Alphabet
{
    public var isFile:Bool = false;

    public function new(x:Float, y:Float, text:String = "", ?bold:Bool = true, ?isFile:Bool = false) {
        super(x, y, text, bold);
        this.isFile = isFile;
    }
}