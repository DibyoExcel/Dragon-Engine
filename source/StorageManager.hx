package;

import lime.system.JNI;

class StorageManager {
    public static function getAndroidStorage():String {
		var getDir = JNI.createStaticMethod("android/os/Environment", "getExternalStorageDirectory", "()Ljava/io/File;");
		var dirFile = getDir();
		var getPath = JNI.createMemberMethod("java/io/File", "getAbsolutePath", "()Ljava/lang/String;");
		return getPath(dirFile);
	}
    public static inline function getEngineDir():String {
        #if (android && MODS_ALLOWED)
        return getAndroidStorage() + '/.DragonEngine/';
        #else
        return '';
        #end
    }
}