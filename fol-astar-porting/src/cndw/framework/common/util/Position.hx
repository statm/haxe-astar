package cndw.framework.common.util;
import de.polygonal.ds.Hashable;
import de.polygonal.ds.HashableItem;
import flash.errors.Error;
import flash.geom.Point;
import flash.Vector;

/**
 * ...
 * @author statm
 */

class Position implements Hashable
{
	private static var POINT_CACHE:Array<Position> = new Array<Position>();

	private static var lock:Bool = true;

	public var key:Int;

	private var row:Int;
	private var col:Int;
	private var neighborList:Vector<Position>;

	/**
	 * 通过行列号获得实例
	 *
	 * @param row 行号
	 * @param col 列号
	 * @return
	 *
	 */
	public static function forRC(row:Int = 0, col:Int = 0):Position {
		var key:Int = (row + 10000) * 10000 + (col + 10000);
		var result:Position = POINT_CACHE[key];
		if (result == null) {
			lock = false;
			result = new Position();
			result.row = row;
			result.col = col;
			result.key = key;
			POINT_CACHE[key] = result;
		}
		return result;

	}

	/**
	 * 通过字符串获得实例
	 *
	 * @param str 用分割符隔开的行和列组成的字符串，必须是先行后列
	 * @param s 指定的分隔符
	 * @return
	 *
	 */
	public static function forString(str:String, s:String = ","):Position {
		var subStrList:Array<String> = str.split(s);
		var r:Int = Std.parseInt(subStrList[0]);
		var c:Int = Std.parseInt(subStrList[1]);
		return forRC(r, c);
	}

	/**
	 * 不建议直接实例化该类
	 *
	 * @param r
	 * @param c
	 *
	 */
	public function new() {
		if (lock) {
			throw new Error("请通过静态构造方法得到实例!");
		}
		lock = true;
	}

	/**
	 * 行号
	 */
	public function getRow():Int {
		return row;
	}

	/**
	 * 列号
	 */
	public function getCol():Int {
		return col;
	}

	/**
	 * 获得此位置与指定位置的直线距离
	 *
	 * @param toPosition
	 * @return
	 *
	 */
	public function distanceTo(toPosition:Position):Float {
		var dx:Int = col - toPosition.col;
		var dy:Int = row - toPosition.row;
		return Math.sqrt(dx * dx + dy * dy);
	}

	/**
	 * 与指定Position对象相加
	 *
	 * @param position
	 * @return
	 *
	 */
	public function add(position:Position):Position {
		return addRC(position.getRow(), position.getCol());
	}

	/**
	 * 增加指定的行和列
	 *
	 * @param row
	 * @param col
	 * @return
	 *
	 */
	public function addRC(row:Int, col:Int):Position {
		return Position.forRC(getRow() + row, getCol() + col);
	}

	/**
	 * 从此位置减去指定的行和列
	 *
	 * @param row
	 * @param col
	 * @return
	 *
	 */
	public function subRC(row:Int, col:Int):Position {
		return Position.forRC(getRow() - row, getCol() - col);
	}

	/**
	 * 从此位置减去指定的位置
	 *
	 * @param position
	 * @return
	 *
	 */
	public function sub(position:Position):Position {
		return subRC(position.getRow(), position.getCol());
	}

	/**
	 * 转成Point对象
	 */
	public function toPoint():Point {
		return new Point(col, row);
	}

	/**
	 * 对比两个位置是否相等
	 *
	 * @param p
	 * @return
	 *
	 */
	public function equal(p:Position):Bool {
		if (p == this) {
			return true;
		} else if (p.getRow() == this.getRow() && p.getCol() == this.getCol()) {
			return true;
		}
		return false;
	}

	public function getKey():Int {
		return key;
	}

	/**
	 * 获得所有的相邻位置(共8个)
	 */
	public function getNeighborList():Vector<Position> {
		if (neighborList == null) {
			neighborList = new Vector<Position>(8, true);
			neighborList[0] = addRC(-1, -1);
			neighborList[1] = addRC(-1, 0);
			neighborList[2] = addRC(-1, 1);
			neighborList[3] = addRC(0, -1);
			neighborList[4] = addRC(0, 1);
			neighborList[5] = addRC(1, -1);
			neighborList[6] = addRC(1, 0);
			neighborList[7] = addRC(1, 1);
		}
		return neighborList;
	}

	public function toString():String {
		return "Position(row=" + getRow() + ", col=" + getCol() + ")";
	}
	
	
}