package com.huafu.sql.query
{
	/**
	 * Represents a SQL condition
	 */
	public class SQLiteCondition
	{
		internal var parameters : Array;
		internal var conditionString : String;
		
		/**
		 * Creates a new SQL condition
		 * 
		 * @param conditionString The SQL code of the condition
		 * @param parameters Each more parameter given to the constructor will be
		 * treated as a bind parameter required for this condition
		 */
		public function SQLiteCondition( conditionString : String, ... parameters : Array )
		{
			this.conditionString = conditionString;
			this.parameters = parameters;
		}
		
		
		/**
		 * Get the SQL code of the condition, automatically binding the parameters to the
		 * given sql parameters object
		 * 
		 * @param parametersDestination Where to bind the parameters if any
		 * @return The SQL code of the condition
		 */
		public function sqlCode( parametersDestination : SQLiteParameters ) : String
		{
			var res : String = conditionString;
			parametersDestination.bind.apply(parametersDestination, parameters);
			return conditionString;
		}
		
		
		/**
		 * Cast anything that can resolve to a SQLiteCondition to an object of this type
		 * 
		 * @param arrayOrCondition Can be a String with the condition, or an array with
		 * the first and second parameter of this class, or even a SQLiteCondition object
		 * in which case this object is just returned
		 * @return The SQLiteCondition object
		 */
		public static function cast( arrayOrCondition : * ) : SQLiteCondition
		{
			if ( arrayOrCondition is SQLiteCondition )
			{
				return arrayOrCondition as SQLiteCondition;
			}
			if ( arrayOrCondition is Array )
			{
				return new SQLiteCondition(arrayOrCondition[0], arrayOrCondition[1]);
			}
			return SQLiteCondition(arrayOrCondition);
		}
	}
}