 /*
 *This file is part of MovieClipCommander Framework.
 *
 *   MovieClipCommander Framework  is free software; you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation; either version 2 of the License, or
 *    (at your option) any later version.
 *
 *    MovieClipCommander Framework is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with MovieClipCommander Framework; if not, write to the Free Software
 *    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
 import iap.commander.MovieClipCommander;

/**
* Matrix extention for MovieClipCommander
* Makes a matrix of cells
* defines a linkage and metrics
* optional to suply extention object to automatic register extentions to each created cell
* optional to supply params
*
* supported parameters
* 	- matrix_cells - an array of all matrix cells
*
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.commander.extentions.Matrix extends iap.services.MovieClipService{
	/**
	* matrixCellAdded - dispatches when an object is being added to the matrix,
	* usually pushed at the end of it.
	* Remark: When a cell is created, this event is dispatched BEFORE the
	*           MCC get all the required extentions registered.
	* 			and even before it's positioned.
	*  extra info: {[B]cell[/B]:the added MCC, [B]index[/B]:__cellsCount}
	*/
	static var EVT_MATRIX_CELL_ADDED:String = "matrixCellAdded";
	/**
	* matrixCellCreated - dispatches when a cell is being created
	* extra info:  {[B]cell[/B]:the added MCC, [B]index[/B]:__cellsCount}
	*/
	static var EVT_MATRIX_CELL_CREATED:String = "matrixCellCreated";
	/**
	* matrixCellDeleted - dispatches when a cell is being removed from matrix
	* extra info:  {[B]cell[/B]:the added MCC, [B]index[/B]:__cellsCount}
	*/
	static var EVT_MATRIX_CELL_REMOVED:String = "matrixCellRemoved";
	/**
	* matrixCellPositioned - dispatches when a cell is being positioned in the matrix
	* extra info: {[B]cell[/B]:the cell being positioned, [B]row[/B]:row, [B[column[/B]:col, [B]x[/B]:nextX, [B]y[/B]:nextY, [B]index[/B]:__cellsCount}
	*/
	static var EVT_MATRIX_CELL_POSITIONED:String = "matrixCellPositioned";
	/**
	* matrixCellIterate - dispatches when iterate command is called
	* extra info: {[B]cell[/B]:the cell being positioned, [B]row[/B]:row, [B[column[/B]:col, [B]index[/B]:__cellsCount}
	* 	and any other extra inf specifyed in the iterate command
	*/
	static var EVT_MATRIX_CELL_ITERATION:String = "matrixCellIterate";
	
	private var __rows:Number;
	private var __columns:Number;
	private var __distanceX:Number;
	private var __distanceY:Number;
	private var __secondX:Number;
	private var __secondY:Number;
	private var __templateName:String;
	private var __templateLinkage:String;
	private var __templateParamsObject:Object;
	private var __templateExtentions:Object;
	private var __templateExtentionsInit:Object;
	private var __templateDynamics:Object;
	private var __offsetX:Number;
	private var __offsetY:Number;

	
	private var __autoMove:Boolean;
	private var __autoDestroy:Boolean;
	private var __createEmpty:Boolean;
	private var __wrapIndex:Boolean;
	
	private var __width:Number;
	private var __height:Number;
	
	private var __cellsCount:Number;
	private var __maximumCells:Number;
	private var __cells:Array;
	private var __locations:Array;
	private var __cellsId:Number;
	
	/**
	* initialize the extention
	* @param	name	the name template to span for all the cells
	* @param	linkage	a linkage from teh library
	* @param	rows	number of rows
	* @param	cols	number of columns
	* @param	x_dis	horiz distance between cells
	* @param	y_dis	vert distance betweem cellas
	* @param	x_2nd	horiz indenting
	* @param	y_2nd	vert indenting
	*/
	function init(name:String, linkage:String, rows:Number, cols:Number, x_dis:Number, y_dis:Number, x_2nd:Number, y_2nd:Number)	{
		cellsTemplate(name, linkage);
		defineMatrix(rows, cols, x_dis, y_dis, x_2nd, y_2nd);
		__templateDynamics = new Object();
		__autoMove = true;
		__autoDestroy = false;
		__offsetX = 0;
		__offsetY = 0;
		__createEmpty = false;
		__wrapIndex = true;
	}
	
	/**
	* define a matrix dimentions.
	* [B]rquired[/B] function to create a matrix
	* @param	rows	number of rows
	* @param	cols	number of columns
	* @param	x_dis	horiz distance between cells
	* @param	y_dis	vert distance betweem cellas
	* @param	x_2nd	horiz indenting
	* @param	y_2nd	vert indenting
	*/
	public function defineMatrix(rows:Number, cols:Number, y_dis:Number, x_dis:Number, y_2nd:Number, x_2nd:Number) {
		__rows = rows;
		__columns = cols;
		__distanceX = (x_dis == undefined)? 0: x_dis;
		__distanceY = (y_dis == undefined)? 0: y_dis;
		__secondX = (x_2nd == undefined)? 0: x_2nd;
		__secondY = (y_2nd == undefined)? 0: y_2nd;
		__maximumCells = __rows * __columns;
		__cells = new Array();
		__commander._params.setParam("matrix_cells", __cells);
		__cellsId = 0;
		__cellsCount = 0;
	}
	
	
	public function defineMatrixByHolder(rows:Number, cols:Number, holder:MovieClipCommander) {
		__rows = rows;
		__columns = cols;
		__distanceX = holder._clip._width / (__columns+1)
		__distanceY = holder._clip._height / __rows
		
		__secondX = 0;
		__secondY = 0;
		__maximumCells = __rows * __columns;
		__cells = new Array();
		__autoMove = true;
		__autoDestroy = false;
		__cellsId = 0;
		__cellsCount = 0;
	}
	
	/**
	* define a matrix template
	* [B]rquired[/B] function to create a matrix
	* @param	name	the name template to span for all the cells
	* @param	linkage	a linkage from teh library
	* @param	paramsObject	an object of parameters to in the new MCC
	*/
	public function cellsTemplate(name:String, linkage:String, paramsObject:Object, createEmpty:Boolean) {
		__createEmpty = createEmpty;
		__templateName = name;
		__templateLinkage = linkage;
		__templateParamsObject = paramsObject;
		if (linkage.length > 0) {
			measureLinkageSize(linkage);
		}
	}
	
	/**
	* define a dynamic template item
	* meaning: given a name and an array, the cells would get a parameter
	* with that name, but with a value in the place of the current index in the array
	* all the rules of linkage and linkage num are valid here
	* @param	dynamicName
	* @param	dynamicArr
	*/
	public function dynamicTemplateItem(dynamicName:String, dynamicArr:Array) {
		__templateDynamics[dynamicName] = dynamicArr;
		__maximumCells = Math.min(__maximumCells, dynamicArr.length);
	}
	
	/**
	* define a set of extentions to register to each cell
	* this is a service function, the same thing can be done
	* whith listenning to matrixCellCreated event
	* @param	extentionsObj	an object - {name: Constructor} of extention to init
	* @param	initObj	an object - {name: [init Array]} of initial parameters to send to the extention init
	*/
	public function extentionsTemplate(extentionsObj:Object, initObj:Object) {
		__templateExtentions = extentionsObj;
		__templateExtentionsInit = initObj;
	}
	
	/**
	* createNextCell - creates the next member in the matrix
	* dispatches: "matrixCellCreated"
	* if specified customeParamsObj.linkage, this will be used for the linkage instead of template
	* @param	customeParamsObj	customParameters for each cell
	* 							linkageNum - attach linkage with serial number
	* @param	autoMove	if auto move is set to false, the cell would not be positioned
	* @return	the created cell
	*/
	public function createNextCell(customeParamsObj:Object, extentionsObj:Object, autoMove:Boolean):MovieClipCommander {
		if (__cellsCount < __maximumCells) {
			var newMc:MovieClipCommander;
			customeParamsObj = getNextTemplate(__cellsId, customeParamsObj);
			if (customeParamsObj.linkage.length > 0 || __createEmpty) {
				newMc = MovieClipCommander(__commander.createChild(__templateName+__cellsId, __commander._depth.higher,customeParamsObj.linkage ));
			} else {
				if (__clip[__templateName+__cellsId] != undefined) {
					newMc = MovieClipCommander(__commander.wrapChild(__templateName+__cellsId));
				}
				// No need to alart for a non existing cell that was not wrapped because
				// then, the wrapping of cells and creation is stopped
			}
			if (newMc != undefined) {
				__cellsId++
				pushToMatrix(newMc, autoMove);
				newMc._params.importObject(customeParamsObj);
				for (var o:String in __templateExtentions) {
					newMc.registerExtention(o, __templateExtentions[o], __templateExtentionsInit[o]);
				}
				for (var o:String in extentionsObj) {
					newMc.registerExtention(o, extentionsObj[o]);
				}
				
				dispatchEvent(EVT_MATRIX_CELL_CREATED, {cell:newMc, index:__cellsCount-1});
				return newMc;
			} else {
				__cellsCount = __maximumCells;
				return undefined;
			}
		} else {
			return undefined;
		}
	}
	
	private function getNextTemplate(index:Number, customeParams:Object) {
		if (customeParams == undefined) {
			customeParams = new Object();
		}
		for (var o:String in __templateParamsObject) {
			customeParams[o] = __templateParamsObject[o];
		}
		for (var o:String in __templateDynamics) {
			customeParams[o] = __templateDynamics[o][index];
		}
		var linkage:String = (customeParams.linkage == undefined)? __templateLinkage:customeParams.linkage;
		if (customeParams.linkageNum != undefined) {
			linkage += customeParams.linkageNum;
		}
		customeParams.linkage = linkage;
		return customeParams;
	}
	
	/**
	* add a MCC to the end of the matrix
	* dispatches: "matrixCellAdded"
	* @param	newMc	the new MCC to add to the matrix
	* @param	autoMove	if auto move is set to false, the cell would not be positioned
	*/
	public function pushToMatrix(newMc:MovieClipCommander, autoMove:Boolean) {
		if (__cellsCount < __maximumCells) {
			__cells[__cellsCount] = newMc;
			dispatchEvent(EVT_MATRIX_CELL_ADDED, {cell:newMc, index:__cellsCount});
			positionCell(__cellsCount, autoMove);
			__cellsCount++;
			return newMc;
		} else {
			return undefined;
		}
	}
	
	/**
	* removes a cell from the matrix
	* dispatches: "matrixCellRemoved"
	* @param	row	the cell's row, or index if column is ommited
	* @param	column	the cell's column in the matrix. If undefined, then the row is threated as index
	* @param	autoMove	if auto move is set to false, the cell would not be positioned
	* @return	the removed cell
	*/
	public function removeFromMatrix(row:Number, column:Number, autoMove:Boolean):MovieClipCommander {
		autoMove = (autoMove == undefined)? __autoMove : autoMove; // ensure no undefined
		var serial:Number = getIndex(row, column);
		var deletedMc:MovieClipCommander = getCell(row, column);
		if (deletedMc != undefined) {
			__cells.splice(serial, 1);
			__cellsCount--;
			dispatchEvent(EVT_MATRIX_CELL_REMOVED, {cell:deletedMc, index:serial});
			for (var i:Number = serial; i<__cellsCount; i++) {
				positionCell(i, autoMove);
			}
			if (__autoDestroy) {
				deletedMc.destroy();
			}
			return deletedMc;
		} else {
			return undefined;
		}
	}
	
	/**
	 * remove a cell from the matric by it ref
	 * @param	cell	a refference to a movieclipcommander
	 */
	public function removeFromMatrixByRef(cell:MovieClipCommander) {
		for (var i:Number = 0; i < __cells.length; i++) {
			if (__cells[i] === cell) {
				removeFromMatrix(i);
				return
			}
		}
	}
	
	/**
	* destroy all the cells in the matrix
	* keep all settings as they are
	*/
	public function destroyMatrix() {
		var autoDestroy:Boolean = _autoDestroy;
		_autoDestroy = true;
		for (var o:String in __cells) {
			removeFromMatrix(Number(o))
		}
		_autoDestroy = autoDestroy;
		__maximumCells = __rows * __columns;
		__cellsId = 0;
		__cellsCount = 0;
	}
	
	/**
	* creates the matrix
	* @param	autoMove	if auto move is set to false, the cell would not be positioned
	*/
	public function createMatrix(autoMove:Boolean) {
		for (var i:Number = 0; i<__maximumCells; i++) {
			createNextCell({},{}, autoMove);
		}
	}
	
	public function measureSize(clip:MovieClip) {
		__width = clip._width;
		__height = clip._height;
	}
	
	public function measureLinkageSize(linkage:String) {
		var testMc:MovieClip = __clip.attachMovie(linkage, "matrix_test_movie_"+_name, Number.MAX_VALUE);
		measureSize(testMc);
		testMc.removeMovieClip();
	}
	
	/**
	* position the cell in the matrix, assigns it's row and column.
	* @param	index	the cell index
	* @param	autoMove	if auto move is set to false, the cell would not be positioned
	*/
	private function positionCell(index:Number, autoMove:Boolean) {
		if (__width == undefined) {
			measureSize(__cells[index]._core._clip);
		}
		autoMove = (autoMove == undefined)? __autoMove : autoMove; // ensure no undefined
		var cellMc:MovieClipCommander = __cells[index];
		var col:Number =index % __columns;
		var row:Number = Math.floor(index / __columns);
		var offsetX:Number = __secondX * (row%2);
		var offsetY:Number = __secondY * (col%2);
		var nextX:Number = col*(__width+__distanceX)+offsetX;
		var nextY:Number = row*(__height+__distanceY)+offsetY;
		cellMc._params.importObject({row:row, column:col, index:index});
		if (autoMove) {
			cellMc._core.move(nextX + __offsetX, nextY + __offsetY);
		}
		dispatchEvent(EVT_MATRIX_CELL_POSITIONED, {cell:cellMc, row:row, column:col, x:nextX, y:nextY, index:__cellsCount});
	}
	
	/**
	* iterate through all the cells in the matrix to enable special commands to all the cells
	* dispatches the matrixCellIterate event so a listener can listen and execute a command on the cell
	* Stops the iteration if the event was handled
	* @param	extraInfo	extra event information to send with the dispatch
	* @return	true if the iteration stopped due to an event that was handled
	*/
	public function iterate(extraInfo:Object):Boolean {
		if (extraInfo == undefined) {
			extraInfo = new Object();
		}
		for (var o:String in __cells) {
			var index:Number = Number(o);
			extraInfo.cell = __cells[o];
			extraInfo.index = index;
			extraInfo.col = index % __columns;
			extraInfo.row = Math.floor(index / __columns);
			var handled:Boolean = dispatchEvent(EVT_MATRIX_CELL_ITERATION, extraInfo, true);
			if (handled) {
				return true;
			}
		}
		return false;
	}
	
	public function getIndex(row:Number, col:Number):Number {
		var serial:Number
		if (col == undefined) {
			// instead of coordinates, the user gave a serial index
			serial  = row;
		} else {
			serial = row * __columns + col;
		}
		if (__wrapIndex) {
			if (serial >= 0) {
				serial = serial % __cells.length;
			} else {
				serial = Math.abs(serial) % (__cells.length);
				serial =  (__cells.length -serial) % __cells.length;
			}
		}
		return serial;
	}
	
	/**
	* get a cell from the matrix
	* @param	row	the row of the cell. can be used as an index, if col not supplied
	* @param	col	the column of the cell
	* @return	the cell MovieClipCommander
	*/
	public function getCell(row:Number, col:Number):MovieClipCommander {
		return __cells[getIndex(row, col)];
	}
	
	/**
	* switch the positions of two cells
	* @param	source
	* @param	dest
	*/
	public function switchCells(source:Number, dest:Number, autoMove:Boolean) {
		source = getIndex(source);
		dest = getIndex(dest);
		var src:MovieClipCommander = __cells[source];
		__cells[source] = __cells[dest];
		__cells[dest] = src;
		for (var i:String in __cells) {
			src = __cells[i];
			if (autoMove == undefined) {
				autoMove = __autoMove;
			}
			positionCell(Number(i), autoMove);
		}
	}
	
//{ GETTER-SETTER
	/**
	* Set to true to have the indexes wrap around,
	* that way an index of 6 to matrix with 4 cells will get the second cell
	*/
	public function set _wrapIndex(p_wrapIndex:Boolean) {
		this.__wrapIndex = p_wrapIndex;
	}
	public function get _wrapIndex():Boolean {
		return this.__wrapIndex;
	}
	/**
	* set to true in order to create empty clips if no linkage is supplied
	*/
	public function set _createEmpty(p_createEmpty:Boolean) {
		this.__createEmpty = p_createEmpty;
	}
	public function get _createEmpty():Boolean {
		return this.__createEmpty;
	}
	/**
	* number of cells in the matrix
	*/
	public function get _count():Number {
		return __cellsCount;
	}
	
	/**
	* limit the number of cells in the matrix
	*/
	public function get _limit():Number {
		return __maximumCells;
	}
	public function set _limit(val:Number) {
		__maximumCells = val;
	}
	
	/**
	* if set to true, the cells automatically moves to the proper position
	*/
	public function get _autoMove():Boolean{
		return __autoMove;
	}
	public function set _autoMove( val:Boolean ):Void{
		__autoMove = val;
	}

	/**
	* automaticaly destroys the cells when their being removed from matrix
	*/
	public function get _autoDestroy():Boolean{
		return __autoDestroy;
	}
	public function set _autoDestroy( val:Boolean ):Void{
		__autoDestroy = val;
	}

	public function get _cellWidth():Number {
		return __width + __distanceX;
	}
	
	public function set _cellWidth(val:Number) {
		__width = val;
	}

	public function get _cellHeight():Number {
		return __height + __distanceY;
	}
	
	public function set _cellHeight(val:Number) {
		__height = val;
	}
	public function set _offsetX(p_offsetX:Number) {
		this.__offsetX = p_offsetX;
	}
	public function set _offsetY(p_offsetY:Number) {
		this.__offsetY = p_offsetY;
	}
	public function get _offsetX():Number {
		return this.__offsetX;
	}
	public function get _offsetY():Number {
		return this.__offsetY;
	}
	
	public function get _cells():Array {
		return __cells
	}
//}
}
