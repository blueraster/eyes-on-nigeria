package base
{
	import mx.controls.Alert;
	import mx.rpc.Fault;
	
	public class Debug
	{
		//this function is global so that error handling is consistant whether it is using alerts or whatever.
		public static function handleLoadError(oFault:Fault, sErrorContext:String):void {
			var sMessage:String = oFault.faultString;
			if (oFault.faultDetail) {
				if (sMessage.length > 0) {
					sMessage += " (" + oFault.faultDetail + ")";
				} else {
					sMessage = oFault.faultDetail;
				}
			}
			trace(">>>>>>>>>> ERROR >>>>>>>>>> " + sMessage);
			Alert.show(sMessage, sErrorContext);
		}
		
		public static function handleError(sMessage:String, sErrorContext:String):void {
			trace(">>>>>>>>>> ERROR >>>>>>>>>> " + sMessage);
			Alert.show(sMessage, sErrorContext);
		}
		
		/*
		//this function is global because often programmers needs to trace the contents of an object
		public static function debugObject(oObj:Object, sIndent:String=" -- ", nMaxLevel:Number=-1, nCurrentLevel:Number=1):void {
			if (nMaxLevel > -1 && nCurrentLevel > nMaxLevel) {
				trace(sIndent + "...");
			} else {
				if (typeof(oObj) == "xml") {
					var oChildren:XMLList;
					var i:Number;
					var sName:String;
					
					trace(sIndent + " Attributes:");
					oChildren = oObj.attributes();
					for (i=0; i<oChildren.length(); i++) {
						trace(sIndent + "[" + oChildren[i].name() + "] = " + oChildren[i]);
					}
					
					oChildren = oObj.children();
					if (oChildren.length() == 0) {
						trace(sIndent + " Text: " + oObj.text());
					} else {
						trace(sIndent + " Child nodes:");
						for (i=0; i<oChildren.length(); i++) {
							sName = oChildren[i].name();
							if (sName) {} else { sName = i.toString() }
							if (typeof(oChildren[i]) == "xml") {
								trace(sIndent + "[" + sName + "]:");
								debugObject(oChildren[i], sIndent + "  ", nMaxLevel, nCurrentLevel+1);
							} else {
								trace(sIndent + "[" + sName + "] = " + oChildren[i]);
							}
						}
					}
				} else {
					for (var item:String in oObj) {
						if (typeof(oObj[item]) == "object") {
							trace(sIndent + "[" + item + "]:");
							debugObject(oObj[item], sIndent + "  ", nMaxLevel, nCurrentLevel+1);
						} else {
							trace(sIndent + "[" + item + "] = " + oObj[item]);
						}
					}
				}
			}
		}
		*/
	}
}