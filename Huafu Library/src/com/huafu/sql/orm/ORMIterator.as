package com.huafu.sql.orm
{
	import com.huafu.sql.SQLiteStatement;
	
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.IllegalOperationError;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import mx.collections.ArrayList;

	/**
	 * Used to browse a result with rows that each contains an ORM object
	 */
	public class ORMIterator extends Proxy
	{
		/**
		 * The data which is browsed is stored here
		 */
		private var _data : ArrayList;
		/**
		 * The statement object
		 */
		private var _statement : SQLiteStatement;
		/**
		 * If given, when the iteration will be initiated, the data wil be binded to
		 * the statement using this object
		 */
		private var _objectUsedToReaload : Object;
		/**
		 * A pointer to the ORM class that this iterator delivers
		 */
		private var _ormClass : Class;
		/**
		 * The instance of ORM object used by this object
		 */
		private var _ormInstance : ORM;
		/**
		 * Stores whether to executre the statement on each new iteration or not
		 */
		private var _loadOnEveryNewIteration : Boolean;
		
		
		/**
		 * Creates a new ierator for the given ORM class and data/statement
		 * 
		 * @param ormClass The ORM class of the models that this iterator will iterate
		 * @param statementOrData Either a SQLStatement or anything thta can cast to an array.
		 * If a SQLStatement is given, it'll be executed and used to get the ORM objects to iterate.
		 * If it's an Array or anything that can cast to an Array, it'll be used as the list of
		 * ORM objects to iterate through
		 * @param objectUsedToBindParameters The object used to (re)bind parameters to
		 * the statement given as second parameter when a new iteration occurs. You MUST provide it
		 * when the second parameter is a statement and you want the iterator to (re)load the
		 * data on the first iteration (and each other new iteration if the last parameter is true)
		 * @param loadOnEveryNewIteration If true, the statement will be binded with parameters
		 * and executed not only for the first iteraton, but for every new iteration
		 */
		public function ORMIterator( ormClass : Class, statementOrData : *, objectUsedToBindParameters : Object = null, loadOnEveryNewIteration : Boolean = false )
		{
			_objectUsedToReaload = objectUsedToBindParameters;
			_statement = statementOrData is SQLStatement ? statementOrData : null;
			_loadOnEveryNewIteration = loadOnEveryNewIteration;
			if ( _objectUsedToReaload )
			{
				_data = null;
			}
			else
			{
				_data = new ArrayList(_statement ? _statement.getResult().data : statementOrData);
			}
			_ormClass = ormClass;
		}
		
		
		/**
		 * The global ORM instance of the iterator
		 */
		private function get ormInstance() : ORM
		{
			if ( !_ormInstance )
			{
				_ormInstance = ORM.factory(_ormClass);
			}
			return _ormInstance;
		}
		
		
		/**
		 * The number of items in the collection
		 */
		public function get count() : int
		{
			if ( !_data )
			{
				_load();
			}
			return _data.length;
		}
		
		
		/**
		 * Get all the items in an array
		 * 
		 * @return The array containing all ORM instances that this iterator would have ran through
		 */
		public function toArray() : Array
		{
			var res : Array = new Array(), item : ORM;
			for each ( item in this )
			{
				res.push(item);
			}
			return res;
		}
		
		
		flash_proxy override function nextNameIndex( index : int ) : int
		{
			if ( index == 0 && _objectUsedToReaload && (_loadOnEveryNewIteration || !_data) )
			{
				_load();
			}
			if ( index >= _data.length )
			{
				return 0;
			}
			return index + 1;
		}
		
		
		flash_proxy override function nextName( index : int ) : String
		{
			return String(index - 1);
		}
		
		
		flash_proxy override function nextValue( index : int ) : *
		{
			return _get(index - 1);
		}
		
		
		flash_proxy override function getProperty( name : * ) : *
		{
			if ( name is String )
			{
				throw new IllegalOperationError("You cannot access property '" + name + "' on an ORMIterator");
			}
			if ( !_data )
			{
				_load();
			}
			return _get(name);
		}
		
		
		/**
		 * Used to (re)load the data
		 */
		private function _load() : void
		{
			var name : String, cleanName : String, paramsDiffers : Boolean = false;
			// (re)bind the parameters
			for ( name in _statement.parameters )
			{
				cleanName = name.substr(1);
				if ( _objectUsedToReaload.hasOwnProperty(cleanName) )
				{
					if ( !paramsDiffers && _statement.parameters[name] != _objectUsedToReaload[cleanName] )
					{
						paramsDiffers = true;
					}
					_statement.parameters[name] = _objectUsedToReaload[cleanName];
				}
			}
			// re-execute only if the parameters are new, or no data yet, or force reload on
			// every new iteration
			if ( _loadOnEveryNewIteration || !_data || paramsDiffers )
			{
				_statement.safeExecute();
				_data = new ArrayList(_statement.getResult().data);
			}
		}
		
		
		/**
		 * Get an item looking at its index, creating the ORM instance for it if not created yet
		 *
		 * @param index The index of the item to get
		 * @return ORM The ORM instance for thi item
		 */
		private function _get( index : int ) : ORM
		{
			var res : ORM, v : *;
			if ( !((v = _data.getItemAt(index)) is ORM) )
			{
				res = ORM.factory(_ormClass);
				res.loadDataFromSqlResult(v);
				_data.setItemAt(res, index);
				return res;
			}
			return v;
		}
	}
}