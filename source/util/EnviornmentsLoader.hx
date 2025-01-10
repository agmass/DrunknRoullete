package util;

class EnviornmentsLoader
{
	public static var enviornments:Array<String> = [];

    /**
    *	WARNING!! expensive if a lot of assets. only use when initializing
    */
    public static function loadEnviornments()
    {
        for (i in AssetPaths.allFiles)
        {
            if (StringTools.startsWith(i, "assets/images/enviorments/"))
            {
                if (!enviornments.contains(i))
                {
                    enviornments.push(i);
                    trace("Enviornment loaded:" + i);
                }
            }
        }
	}
}
