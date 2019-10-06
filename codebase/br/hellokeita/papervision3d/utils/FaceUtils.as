package br.hellokeita.papervision3d.utils{
	
	import org.papervision3d.core.Number3D;
	import org.papervision3d.core.geom.Face3D;
	
	public class FaceUtils{
		
		public function FaceUtils(){};
		
		public static function normalize(face):Number3D{
			var vn0, vn1, vn2, vt1, vt2:Number3D;
			if(face is Face3D){
				vn0 = face.v0.toNumber3D();
				vn1 = face.v1.toNumber3D();
				vn2 = face.v2.toNumber3D();
			}else if(face is Array){
				vn0 = face[0].toNumber3D();
				vn1 = face[1].toNumber3D();
				vn2 = face[2].toNumber3D();
			}
			vt1 = Number3D.sub(vn1,vn0);
			vt2 = Number3D.sub(vn2,vn0);
			
			var fn = Number3D.cross(vt2,vt1);
			fn.normalize();
		
			return fn;
		}
	}
}