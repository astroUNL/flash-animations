package br.hellokeita.utils 
{
	
	/**
	 * @author		keita (keita.kun at gmail.com)
	 * @svn			http://code.hellokeita.in/public
	 * @url			http://labs.hellokeita.com/
	 * 
	 * The MathUtils class is bunch of mathematical methods.
	 */
	public class MathUtils 
	{
		
		/**
		* Solve combinations
		*
		* Passing 2 parameters <code>n</code> and <code>k</code> it calculates the combination defined by <code>(n!) / (k! * (n - k)!)</code>
		* 
		* @param number of objects from which you can choose
		* @param number to be chosen
		* 
		* @return number of combination
		*
		* @see http://en.wikipedia.org/wiki/Combination
		*/
		static public function combination(a:uint, b:uint):uint {
			if (a == b) return 1;
			if (b == 0) return 1;
			if (a < b) return 1;
			var d:uint = a - b;
			var s:uint;
			if (d > b) {
				s = d + 1;
				d = 1 / factorial(b);
			}else {
				s = b + 1;
				d = 1 / factorial(d);
			}
			return factorial(a, s) * d;
		}
		
		/**
		* Calculates factorial
		*
		* Calculates the factorial of a number.
		* Also, passing the start value you can choose the range of the factorial, useful to solve <code>combination()</code>
		* 
		* @param number of factorial
		* @param [optional] start number for the factorial
		* 
		* @return product of each positive integer value between <code>start</code> to <code>value</code>
		*
		* @see http://en.wikipedia.org/wiki/Factorial
		*/
		static public function factorial(value:uint, start:uint = 1):uint {
			if (start > value) return 0;
			if (value == start) return value;
			var r:uint = 1;
			for (var i:uint = start; i <= value; i++) {
				r *= i;
			}
			
			return r;
		}
		
/**
* Solve equation system using Cramer's rule
*
* Solves an equation system using Cramer's rule.
* 
* @example <p>Having 2 equation with 2 unknown values such as <code>3 ~~ a + 1 ~~ b = 3</code> and <code>5 ~~ a - 2 ~~ b = 20</code></p>
* <listing version="3.0">
* MathUtils.solveCramer([
* 	3, 1, 3, 
* 	5, -2, 20
* ]);
* </listing>
* 
* Will return [2.3636363636363638,-4.090909090909091]
* 
* @param Array of values that multiplies the unknown value
* 
* @return Array of values with number of unknown values size that solves the system.
*
* @see http://en.wikipedia.org/wiki/Cramer%27s_rule
*/
		static public function solveCramer(matrix:Array):Array {
			var l:uint = matrix.length;
			var size:uint = Math.sqrt(l);
			if (l != size * size + size) return null;
			
			var result:Array = [];
			var r:Array = [];
			var vs:Array = [];
			
			var d:Number;
			var i:uint, j:uint;
			var p:int;
			for (i = 0; i < size; i++) {
				p = i * (size + 1);
				vs = [].concat(vs, matrix.slice(p, p + size));
				r[i] = matrix[p + size];
			}
			d = 1 / squareMatrixDeterminant(vs);
			
			var tArr:Array;
			for (i = 0; i < size; i++) {
				tArr = [].concat(vs);
				for (j = 0; j < size; j++) {
					tArr[i + j * size] = r[j];
					result[i] = squareMatrixDeterminant(tArr) * d;
				}
			}
			
			return result;
			
		}
		
		/**
		* Calculates the determinant of any size of a square matrix.
		*
		* @param Array of values of the matrix
		* 
		* @return Matrix determinant
		*
		* @see http://en.wikipedia.org/wiki/Determinant
		*/
		static public function squareMatrixDeterminant(matrix:Array):Number {
			var l:int = matrix.length;
			var s:int = Math.sqrt(l);
			if (l != s * s) return Number.NaN;
			
			return _squareMatrixDeterminant(matrix, s);
			
		}
		
		static private function _squareMatrixDeterminant(matrix:Array, size:uint ):Number {
			
			if (size < 1) return Number.NaN;
			if (size == 1) return matrix[0];
			
			if (size == 2) {
				return matrix[0] * matrix[3] - matrix[1] * matrix[2];
			}
			
			var i:int, j:int, h:int;
			var r:Number = 0;
			var tArr:Array;
			var c:int;
			var s:int = 1;
			for (i = 0; i < size; i++) {
				c = 0;
				tArr = [];
				for (j = 1; j < size; j++) {
					for (h = 0; h < size; h++) {
						if (h == i) continue;
						tArr[c++] = matrix[j * size + h];
					}
				}
				
				r += matrix[i] * _squareMatrixDeterminant(tArr, size - 1) * s;
				s *= -1;
				
			}
			
			return r;
			
		}
		
	}
	
}