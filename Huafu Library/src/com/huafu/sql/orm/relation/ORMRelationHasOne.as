package com.huafu.sql.orm.relation
{
	import com.huafu.sql.orm.ORM;
	import com.huafu.sql.orm.ORMDescriptor;
	import com.huafu.sql.orm.ORMPropertyDescriptor;
	import com.huafu.sql.query.SQLiteCondition;
	import com.huafu.sql.query.SQLiteQuery;
	import com.huafu.utils.reflection.ReflectionMetadata;
	import com.huafu.utils.reflection.ReflectionProperty;
	
	public class ORMRelationHasOne extends ORMRelation implements IORMRelation
	{
		protected var _nullable : Boolean;
		
		public function ORMRelationHasOne( ownerDescriptor : ORMDescriptor, property : ReflectionProperty, metadata : ReflectionMetadata )
		{
			super(ownerDescriptor, property, metadata);
			_foreignIsUnique = true;
			_foreignColumnName = metadata.argValueString("foreignColumn");
			_nullable = metadata.argValueBoolean("nullable", false);
			_localColumnName = metadata.argValueString("column");
			_foreignOrmClass = property.dataTypeClass;
		}
		
		
		override public function get foreignColumnName() : String
		{
			if ( !_foreignColumnName )
			{
				_foreignColumnName = foreignDescriptor.primaryKeyProperty.columnName
			}
			return _foreignColumnName;
		}
		
		
		public function get isNullable() : Boolean
		{
			return _nullable;
		}
		
		
		override public function get localColumnSqlCode() : String
		{
			var p : ORMPropertyDescriptor;
			if ( !_localColumnSqlCode )
			{
				if ( (p = ownerDescriptor.propertyDescriptorByColumnName(localColumnName)) )
				{
					return p.sqlCode;
				}
				p = foreignDescriptor.propertyDescriptorByColumnName(foreignColumnName);
				_localColumnSqlCode = "\"" + localColumnName + "\" " + p.columnDataType;
				if ( p.columnDataLength > 0 )
				{
					_localColumnSqlCode += "(" + p.columnDataLength + ")";
				}
				_localColumnSqlCode += " " + (isNullable ? "" : "NOT ") + "NULL";
			}
			return _localColumnSqlCode;
		}
		
		
		override public function get localColumnName():String
		{
			if ( !_localColumnName )
			{
				_localColumnName = foreignDescriptor.tableName + "_id";
			}
			return _localColumnName;
		}
		
		
		public function setupOrmObject( ormObject : ORM, ormObjectData : Object, usingData : Object ) : void
		{
			var res : ORM = ormObjectData[ownerPropertyName] || null;
			if ( !usingData || !usingData[localColumnName] )
			{
				ormObjectData[ownerPropertyName] = null;
				return;
			}
			if ( !res )
			{
				res = new foreignOrmClass();
				ormObjectData[ownerPropertyName] = res;
			}
			res.excludeSoftDeleted = ormObject.excludeSoftDeleted;
			res.find(usingData[localColumnName]);
			if ( !res.isLoaded )
			{
				ormObjectData[ownerPropertyName] = null;
			}
		}
	}
}