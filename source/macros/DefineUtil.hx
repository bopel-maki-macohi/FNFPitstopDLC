package macros;

class DefineUtil
{
	public static macro function getDefine(define:String, ?defaultValue:String):Expr
	{
		return macro $v{haxe.macro.Context.definedValue(define) ?? defaultValue ??  null};
	}

	public static macro function isDefined(define:String):Expr
	{
		return macro $v{haxe.macro.Context.definedValue(define) != null};
	}
}
