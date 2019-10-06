package br.hellokeita.papervision3d.utils{
	
	
	public class VertexUtils{
		
		private static var filterObject:Object;
		
		public function VertexUtils(){};
		
		public static function getVertices(arr, x:*, y:*, z:*){
			filterObject = {x: x, y: y, z: z};
			arr = arr.filter(filterVertices);
			filterObject = null;
			
			return arr;
		}
		
		private static function filterVertices(e, i, a){
			if(!isNaN(filterObject.x) && (filterObject.x != e.x)) return false;
			if(!isNaN(filterObject.y) && (filterObject.y != e.y)) return false;
			if(!isNaN(filterObject.z) && (filterObject.z != e.z)) return false;
			return true;
		}
	}
}