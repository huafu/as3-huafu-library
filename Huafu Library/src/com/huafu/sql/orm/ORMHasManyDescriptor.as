package com.huafu.sql.orm
{
	import com.huafu.sql.SQLiteStatement;
	import com.huafu.utils.reflection.ReflectionProperty;

	/**
	 * Describe and handle a "has many" relation property in a model
	 */
	public class ORMHasManyDescriptor extends ORMRelationDescriptorBase implements IORMRelationDescriptor
	{
		/**
		 * The name of the column in the related table
		 */
		private var _relatedColumnName : String;
		
		
		/**
		 * Creates a new has many relation descriptor
		 * 
		 * @param ormDescriptor The ORM descriptor that holds the property corresponding to a relation
		 * @param propertyName The property name in the owner descriptor
		 * @param relatedClass The class of the related ORM
		 * @param realtedColumnName The name of the column in the related table
		 */
		public function ORMHasManyDescriptor( ormDescriptor : ORMDescriptor, propertyName : String, relatedClass : Class, relatedColumnName : String )
		{
			super(ormDescriptor, propertyName, relatedClass);
			_relatedColumnName = relatedColumnName;
		}
		
		
		/**
		 * Name of the column in the owner descriptor responsible to make the realtion
		 */
		public function get columnName() : String
		{
			return ormDescriptor.primaryKeyProperty.columnName;
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get columnSqlCode() : String
		{
			// we return null because it's using the PK of the table which is of course already a column
			return null;
		}
		
		
		/**
		 * The name of the column in the related descriptor
		 */
		public function get relatedColumnName() : String
		{
			return _relatedColumnName;
		}
		
		
		/**
		 * Setup the property of an ORM object looking at this realtion
		 * 
		 * @param ormObject The ORM object to setup property of
		 * @param dataObject The dataObject that the ORM object holds
		 * @param resultRow The result row object containing data for this relation
		 */
		public function setupOrmObject( ormObject : ORM, dataObject : Object, resultRow : Object ) : void
		{
			var res : ORMIterator, stmt : SQLiteStatement, sql : String;
			if ( dataObject[propertyName] )
			{
				return;
			}
			sql = "SELECT * FROM " + relatedOrmDescriptor.tableName + " WHERE " + relatedColumnName + " = :" + propertyName;
			stmt = ormObject.connection.createStatement(ORM.PREPEND_SQL_COMMENT + sql, true);
			// set the parameter to something so that the ORMIterator can detect it and bind it
			stmt.bind(propertyName, null);
			res = new ORMIterator(ormDescriptor.ormClass, stmt, dataObject);
			dataObject[propertyName] = res;
		}
	}
}