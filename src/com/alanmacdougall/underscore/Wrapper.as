package com.alanmacdougall.underscore {
// imports

public class Wrapper {
	internal var _wrapped:*;
	internal var _chain:Boolean = false;
	
	public function Wrapper(obj:*) {
		_wrapped = obj;
	}
	
	public function chain():* {
		_chain = true;
		return this;
	}
	
	public function value():* {
		_chain = false;
		return _wrapped;
	}
}
}
