package com.huafu.utils
{
	
	import mx.collections.ArrayList;
	import mx.utils.ArrayUtil;

	public class HashMap
	{
		private var _keys : ArrayList;
		private var _data : Object;
		
		
		public function HashMap( initialData : Object = null )
		{
			var key : String;
			
			_keys = new ArrayList();
			_data = {};
			if ( initialData )
			{
				if ( initialData is HashMap )
				{
					initialData = (initialData as HashMap).toObject();
				}
				for ( key in initialData )
				{
					_set(key, initialData[key]);
				}
			}
		}
		
		
		public function unset( name : String ) : Boolean
		{
			var index : int;
			if ( (index = _keyIndex(name)) != -1 )
			{
				_keys.removeItemAt(index);
				delete _data[name];
				return true;
			}
			return false;
		}
		
		
		public function set( name : String, value : * ) : HashMap
		{
			_set(name, value, (_keyIndex(name) == -1));
			return this;
		}
		
		
		public function get( name : String ) : *
		{
			if ( _keyIndex(name) == -1 )
			{
				return undefined;
			}
			return _data[name];
		}
		
		
		public function exists( name : String ) : Boolean
		{
			return (_keyIndex(name) != -1);
		}
		
		
		public function toObject() : Object
		{
			var res : Object = {};
			forEach(function(key : String, value : *, index : int) : void
			{
				res[key] = value;
			});
			return res;
		}
		
		
		public function keys() : Array
		{
			return _keys.toArray();
		}
		
		
		public function forEach( iterator : Function, context : Object = null ) : void
		{
			var index : int = 0, key : String;
			for each ( key in _keys )
			{
				iterator.apply(context, [key, _data[key], index++]);
			}
		}
		
		
		private function _set( name : String, value : *, addNameToKeys : Boolean = true ) : void
		{
			_data[name] = value;
			if ( addNameToKeys )
			{
				_keys.addItem(name);
			}
		}
		
		private function _keyIndex( name : String ) : int
		{
			return _keys.getItemIndex(name);
		}
	}
}