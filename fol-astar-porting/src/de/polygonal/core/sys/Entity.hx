/*
 *                            _/                                                    _/
 *       _/_/_/      _/_/    _/  _/    _/    _/_/_/    _/_/    _/_/_/      _/_/_/  _/
 *      _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/
 *     _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/
 *    _/_/_/      _/_/    _/    _/_/_/    _/_/_/    _/_/    _/    _/    _/_/_/  _/
 *   _/                            _/        _/
 *  _/                        _/_/      _/_/
 *
 * POLYGONAL - A HAXE LIBRARY FOR GAME DEVELOPERS
 * Copyright (c) 2009 Michael Baczynski, http://www.polygonal.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.polygonal.core.sys;

import de.polygonal.core.event.IObservable;
import de.polygonal.core.event.IObserver;
import de.polygonal.core.event.Observable;
import de.polygonal.core.fmt.Sprintf;
import de.polygonal.core.fmt.StringUtil;
import de.polygonal.core.math.Limits;
import de.polygonal.core.macro.Assert;
import de.polygonal.ds.Bits;
import de.polygonal.ds.TreeNode;

class Entity implements IObserver, implements IObservable
{
	inline public static var UPDATE_ANCESTOR_ADD      = BIT_ADD_ANCESTOR;
	inline public static var UPDATE_ANCESTOR_REMOVE   = BIT_REMOVE_ANCESTOR;
	
	inline public static var UPDATE_DESCENDANT_ADD    = BIT_ADD_DESCENDANT;
	inline public static var UPDATE_DESCENDANT_REMOVE = BIT_REMOVE_DESCENDANT;
	
	inline public static var UPDATE_SIBLING_ADD       = BIT_ADD_SIBLING;
	inline public static var UPDATE_SIBLING_REMOVE    = BIT_REMOVE_SIBLING;
	
	inline public static var UPDATE_ANCESTOR          = BIT_ADD_ANCESTOR | BIT_REMOVE_ANCESTOR;
	inline public static var UPDATE_DESCENDANT        = BIT_ADD_DESCENDANT | BIT_REMOVE_DESCENDANT;
	inline public static var UPDATE_SIBLING           = BIT_ADD_SIBLING | BIT_REMOVE_SIBLING;
	inline public static var UPDATE_ALL               = UPDATE_ANCESTOR | UPDATE_DESCENDANT | UPDATE_SIBLING;
	
	inline static var BIT_ADVANCE           = Bits.BIT_01;
	inline static var BIT_RENDER            = Bits.BIT_02;
	inline static var BIT_STOP_PROPAGATION  = Bits.BIT_03;
	inline static var BIT_PROCESS_SUBTREE   = Bits.BIT_04;
	inline static var BIT_PENDING_ADD       = Bits.BIT_05;
	inline static var BIT_PENDING_REMOVE    = Bits.BIT_06;
	inline static var BIT_ADDED             = Bits.BIT_07;
	inline static var BIT_REMOVED           = Bits.BIT_08;
	inline static var BIT_PROCESS           = Bits.BIT_09;
	inline static var BIT_COMMIT_REMOVAL    = Bits.BIT_10;
	inline static var BIT_COMMIT_SUICIDE    = Bits.BIT_11;
	inline static var BIT_INITIATOR         = Bits.BIT_12;
	inline static var BIT_RECOMMIT          = Bits.BIT_13;
	inline static var BIT_ADD_ANCESTOR      = Bits.BIT_14;
	inline static var BIT_REMOVE_ANCESTOR   = Bits.BIT_15;
	inline static var BIT_ADD_DESCENDANT    = Bits.BIT_16;
	inline static var BIT_REMOVE_DESCENDANT = Bits.BIT_17;
	inline static var BIT_ADD_SIBLING       = Bits.BIT_18;
	inline static var BIT_REMOVE_SIBLING    = Bits.BIT_19;
	
	inline static var BIT_PENDING = BIT_PENDING_ADD | BIT_PENDING_REMOVE;
	
	#if debug
	inline static var INDEX_ADD               = 0;
	inline static var INDEX_REMOVE            = 1;
	inline static var INDEX_ADD_ANCESTOR      = 2;
	inline static var INDEX_REMOVE_ANCESTOR   = 3;
	inline static var INDEX_ADD_DESCENDANT    = 4;
	inline static var INDEX_REMOVE_DESCENDANT = 5;
	inline static var INDEX_ADD_SIBLING       = 6;
	inline static var INDEX_REMOVE_SIBLING    = 7;
	inline static var INDEX_SUM               = 8;
	static var _stats = [0, 0, 0, 0, 0, 0, 0, 0, 0];
	public static function printTopologyStats():String
	{
		if (_stats[INDEX_ADD] == 0) return null;
		return Sprintf.format('+%-3d-%-3d|A:%-5d %-5d|D:%-5d %-5d|S:%-5d %-5d|%04d', _stats);
	}
	#end
	
	public static var format:Entity->String = null;
	
	/**
	 * The name of this entity.<br/>
	 * The default value is the unqualified class name of this entity.
	 */
	public var name:Dynamic;
	
	/**
	 * The type of this entity.
	 */
	public var type:Int;
	
	/**
	 * The processing order of this entity.<br/>
	 * The smaller the value, the higher the priority.<br/>
	 * The default value is 0xFFFF.
	 */
	public var priority:Int;
	
	/**
	 * If false, <em>onAdvance()</em> is not called on this entity.<br/>
	 * Default ist true.
	 */
	public var doAdvance(get_doAdvance, set_doAdvance):Bool;
	function get_doAdvance():Bool
	{
		return _hasFlag(BIT_ADVANCE);
	}
	function set_doAdvance(value:Bool):Bool
	{
		value ? _setFlag(BIT_ADVANCE) : _clrFlag(BIT_ADVANCE);
		return value;
	}
	
	/**
	 * If false, <em>onRender()</em> is not called on this entity.<br/>
	 * Default ist false.
	 */
	public var doRender(get_doRender, set_doRender):Bool;
	function get_doRender():Bool
	{
		return _hasFlag(BIT_RENDER);
	}
	function set_doRender(value:Bool):Bool
	{
		value ? _setFlag(BIT_RENDER) : _clrFlag(BIT_RENDER);
		return value;
	}
	
	/**
	 * If false, the children of this node are neither updated nor rendered.<br/>
	 * Default is true.
	 */
	public var doChildren(get_doChildren, set_doChildren):Bool;
	function get_doChildren():Bool
	{
		return _hasFlag(BIT_PROCESS_SUBTREE);
	}
	function set_doChildren(value:Bool):Bool
	{
		value ? _setFlag(BIT_PROCESS_SUBTREE) : _clrFlag(BIT_PROCESS_SUBTREE);
		return value;
	}
	
	/**
	 * The tree node that stores this entity.
	 */
	public var treeNode(default, null):TreeNode<Entity>;
	
	var _flags:Int;
	var _observable:Observable;
	var _class:Class<Entity>;
	
	public function new(name:Dynamic = null)
	{
		this.name = name == null ? StringUtil.getUnqualifiedClassName(this) : name;
		treeNode = new TreeNode<Entity>(this);
		priority = Limits.UINT16_MAX;
		_flags = BIT_ADVANCE | BIT_PROCESS_SUBTREE | UPDATE_ALL;
		_observable = null;
		_class = null;
	}
	
	/**
	 * Recursively destroys the subtree rooted at this entity (including this entity) from the bottom up.<br/>
	 * The method invokes <em>onFree()</em> on each entity, giving each entity the opportunity to perform some cleanup (e.g. free resources or unregister from listeners).<br/>
	 * Only effective if <em>commit()</em> is called afterwards.
	 */
	public function free():Void
	{
		if (_hasFlag(BIT_COMMIT_SUICIDE))
		{
			#if log
			de.polygonal.core.log.Log.getLog(Entity).warn(Sprintf.format('entity \'%s\' already freed', [Std.string(name)]));
			#end
			return;
		}
		
		if (treeNode.hasParent())
		{
			_setFlag(BIT_COMMIT_SUICIDE);
			remove();
		}
	}
	
	///TODO
	/**
	 * Whenever an entity is added or removed, the ancestors, descendants and siblings of this entity are notified about the change.<br/>
	 */
	public function hideUpdate(flags:Int):Void//, deep = false, rise = false):Void
	{
		_clrFlag(flags);
		
		/*if (deep)
		{
			var n = treeNode.children;
			while (n != null)
			{
				n.val.setFlag(x, deep);
				n = n.next;
			}
		}
		if (rise)
		{
			var n = treeNode.parent;
			while (n != null)
			{
				n.val.setFlag(x);
				n = n.parent;
			}
		}*/
		
		/*public function clrFlag(x:Int, deep = false):Void
		{
			_clrFlag(x);
			if (deep)
			{
				var n = treeNode.children;
				while (n != null)
				{
					n.val.clrFlag(x, deep);
					n = n.next;
				}
			}
		}*/
	}
	
	public function stopPropagation():Void
	{
		_setFlag(BIT_STOP_PROPAGATION);
	}
	
	public function sleep(deep = false)
	{
		if (deep)
			_clrFlag(BIT_ADVANCE | BIT_RENDER | BIT_PROCESS_SUBTREE);
		else
			_clrFlag(BIT_ADVANCE | BIT_RENDER);
	}
	
	public function wakeup(deep = false)
	{
		if (deep)
			_setFlag(BIT_ADVANCE | BIT_RENDER | BIT_PROCESS_SUBTREE);
		else
			_setFlag(BIT_ADVANCE | BIT_RENDER);
	}
	
	inline public function getParent():Entity
	{
		return treeNode.hasParent() ? treeNode.parent.val : null;
	}
	
	inline public function hasParent():Bool
	{
		return treeNode.hasParent();
	}
	
	public function getChildAtIndex<T>(i:Int):T
	{
		#if debug
		D.assert(i >= 0 && i < treeNode.numChildren(), 'index out of range');
		#end
		
		var n = treeNode.children;
		for (j in 0...i) n = n.next;
		return cast n.val;
	}
	
	public function sortChildren():Void
	{
		var n = treeNode.children;
		while (n != null)
		{
			if (n.val.priority < Limits.INT16_MAX)
			{
				treeNode.sort(_sortChildrenCompare, true);
				break;
			}
			n = n.next;
		}
	}
	
	public function commit():Void
	{
		#if debug
		for (i in 0...9) _stats[i] = 0;
		#end
		
		//always start as high as possible
		var root = treeNode.getRoot();
		var e = root.val;
		
		//defer update if tree is being processed
		if (e._hasFlag(BIT_INITIATOR))
		{
			#if (log && debug)
			de.polygonal.core.log.Log.getLog(Entity).warn('postpone commit at entity ' + name);
			#end
			e._setFlag(BIT_RECOMMIT);
			return;
		}
		
		//early out
		if (!_isDirty())
		{
			_clrFlag(BIT_INITIATOR | BIT_RECOMMIT);
			return;
		}
		
		//lock
		_setFlag(BIT_INITIATOR);
		
		e._prepareAdditions();
		e._registerHi();
		e._registerLo();
		e._register();
		
		e._prepareRemovals();
		e._unregisterHi();
		e._unregisterLo();
		e._unregister();
		e._removeNodes();
		
		//unlock
		_clrFlag(BIT_INITIATOR);
		
		//recursive update?
		if (_hasFlag(BIT_RECOMMIT))
		{
			_clrFlag(BIT_RECOMMIT);
			commit();
		}
	}

	/**
	 * Updates all entities in the subtree rooted at this node (excluding this node) by calling <em>onAdvance()</em> on each node.
	 * @param dt the time step passed to each node.
	 */
	public function advance(dt:Float, ?parent:Entity):Void
	{
		_propagateAdvance(dt, parent == null ? this : parent);
	}
	
	/**
	 * Renders all entities in the subtree rooted at this node (excluding this node) by calling <em>onRender()</em> on each node.
	 * @param  alpha a blending factor in the range <arg>&#091;0, 1&#093;</arg> between the previous and current state.
	 */
	public function render(alpha:Float, ?parent:Entity):Void
	{
		_propagateRender(alpha, parent == null ? this : parent);
	}
	
	/**
	 * Adds a <em>child</em> entity to this entity.
	 */
	public function add(child:Entity, priority = Limits.UINT16_MAX):Void
	{
		if (child._hasFlag(BIT_PENDING_ADD))
		{
			#if log
			de.polygonal.core.log.Log.getLog(Entity).warn(Sprintf.format('entity \'%s\' already added to %s', [child.name, name]));
			#end
			return;
		}
		
		#if debug
		D.assert(!treeNode.contains(child), 'given entity is a child of this entity');
		#if log
		if (treeNode.getRoot().val._hasFlag(BIT_INITIATOR))
			de.polygonal.core.log.Log.getLog(Entity).warn(Sprintf.format('entity \'%s\' added during tree update', [child.name]));
		#end
		#end
		
		if (priority != Limits.UINT16_MAX) child.priority = priority;
		
		//modify tree
		treeNode.appendNode(child.treeNode);
		
		//mark as pending addition
		child._clrFlag(BIT_PENDING_REMOVE);
		child._setFlag(BIT_PENDING_ADD);
	}
	
	/**
	 * Removes a <em>child</em> entity from this entity or this entity if <em>child</em> is omitted.
	 * @param deep if true, recursively removes all nodes in the subtree rooted at this node.
	 */
	public function remove(?child:Entity, deep = false):Void
	{
		if (child == null)
		{
			//remove this entity
			if (getParent() == null)
			{
				#if log
				de.polygonal.core.log.Log.getLog(Entity).warn('root node can\'t be removed.');
				#end
				return;
			}
			getParent().remove(this, deep);
			return;
		}
		
		if (child._hasFlag(BIT_PENDING_REMOVE | BIT_COMMIT_REMOVAL))
		{
			#if log
			de.polygonal.core.log.Log.getLog(Entity).warn(Sprintf.format('entity \'%s\' already removed from \'%s\'', [Std.string(child.name), Std.string(name)]));
			#end
			return;
		}
		
		#if debug
		D.assert(child != this, 'given entity (%s) equals this entity.');
		D.assert(treeNode.contains(child), Sprintf.format('given entity (%s) is not a child of this entity (%s).', [Std.string(child.name), Std.string(name)]));
		#if log
		if (treeNode.getRoot().val._hasFlag(BIT_INITIATOR))
			de.polygonal.core.log.Log.getLog(Entity).warn(Sprintf.format('entity \'%s\' removed during tree update', [child.name]));
		#end
		#end
		
		child.sleep();
		
		//mark as pending removal
		child._clrFlag(BIT_PENDING_ADD);
		child._setFlag(BIT_PENDING_REMOVE);
		
		if (_hasFlag(BIT_COMMIT_REMOVAL))
		{
			//this node was marked for removal, so child can be removed directly
			child._setFlag(BIT_COMMIT_REMOVAL);
			child._clrFlag(BIT_PENDING_REMOVE);
			child.sleep();
			child.onRemove(this);
			#if debug
			_stats[INDEX_REMOVE]++;
			_stats[INDEX_SUM]++;
			#end
		}
		
		if (deep)
		{
			var n = child.treeNode.children;
			while (n != null)
			{
				remove(n.val, deep);
				n = n.next;
			}
		}
	}
	
	/**
	 * Removes all child entities.
	 * @param deep if true, recursively removes all nodes in the subtree rooted at this node.
	 */
	public function removeChildren(deep = false):Entity
	{
		var n = treeNode.children;
		while (n != null)
		{
			remove(n.val);
			if (deep) n.val.removeChildren(deep);
			n = n.next;
		}
		return this;
	}
	
	/**
	 * Returns the first occurrence of an entity whose name matches <code>x</code> or null if no entity was found.
	 * @param deep if true, searches the entire subtree rooted at this node.
	 */
	public function findChildById(x:Dynamic, deep = false):Entity
	{
		if (deep)
		{
			for (i in treeNode)
			{
				if (i == this) continue;
				if (i.name == x) return i;
			}
			return null;
		}
		else
		{
			var n = treeNode.children;
			while (n != null)
			{
				var e = n.val;
				if (e.name == x) return e;
				n = n.next;
			}
		}
		return null;
	}
	
	/**
	 * Returns the first occurrence of an entity whose class matches <code>x</code> or null if no entity was found.
	 * @param deep if true, searches the entire subtree rooted at this node.
	 */
	public function findChildByClass<T>(x:Class<T>, deep = false):T
	{
		var c:Class<Dynamic>;
		if (deep)
		{
			for (i in treeNode)
			{
				if (i == this) continue;
				c = i._getClass();
				if (c == x) return cast i;
			}
		}
		else
		{
			var n = treeNode.children;
			while (n != null)
			{
				var e = n.val;
				c = e._getClass();
				if (c == x) return cast e;
				n = n.next;
			}
		}
		return null;
	}
	
	/**
	 * Returns the first occurrence of an entity whose name matches <code>x</code> or null if no entity was found.
	 */
	public function findSiblingById(x:Dynamic):Entity
	{
		var n = treeNode.getFirstSibling();
		while (n != null)
		{
			var e = n.val;
			if (e.name == x) return e;
			n = n.next;
		}
		return null;
	}
	
	/**
	 * Returns the first occurrence of an entity whose class matches <code>x</code> or null if no entity was found.
	 */
	public function findSiblingByClass<T>(x:Class<T>):T
	{
		var c:Class<Dynamic>;
		var n = treeNode.getFirstSibling();
		while (n != null)
		{
			var e = n.val;
			c = e._getClass();
			if (c == x) return cast e;
			n = n.next;
		}
		return null;
	}
	
	/**
	 * Returns the first occurrence of an entity whose name matches <code>x</code> or null if no entity was found.
	 */
	public function findParentById(x:Dynamic):Entity
	{
		var n = treeNode.parent;
		while (n != null)
		{
			var e = n.val;
			if (e.name == x) return e;
			n = n.parent;
		}
		return null;
	}
	
	/**
	 * Returns the first occurrence of an entity whose class matches <code>x</code> or null if no entity was found.
	 */
	public function findParentByClass<T>(x:Class<T>):T
	{
		var c:Class<Dynamic>;
		var n = treeNode.parent;
		while (n != null)
		{
			var e = n.val;
			c = e._getClass();
			if (c == x) return cast e;
			n = n.parent;
		}
		return null;
	}
	
	/**
	 * Sends a message <code>x</code> to all ancestors of this node.<br/>
	 * Bubbling can be aborted by calling <em>stopPropagation()</em>.
	 */
	public function liftMessage(x:String, userData:Dynamic = null):Void
	{
		var n = treeNode.parent;
		while (n != null)
		{
			var e = n.val;
			if (e._hasFlag(BIT_PENDING | BIT_COMMIT_SUICIDE)) break;
			e._clrFlag(BIT_STOP_PROPAGATION);
			e.onMessage(x, userData);
			if (e._hasFlag(BIT_STOP_PROPAGATION)) break;
			n = n.parent;
		}
	}
	
	/**
	 * Sends a message <code>x</code> to all descendants of this node.<br/>
	 * Bubbling can be aborted by calling <em>stopPropagation()</em>.
	 */
	public function dropMessage(x:String, userData:Dynamic = null):Void
	{
		var n = treeNode.children;
		while (n != null)
		{
			var e = n.val;
			if (e._hasFlag(BIT_PENDING | BIT_COMMIT_SUICIDE))
			{
				n = n.next;
				continue;
			}
			e._clrFlag(BIT_STOP_PROPAGATION);
			e.onMessage(x, userData);
			if (e._hasFlag(BIT_STOP_PROPAGATION)) break;
			e.dropMessage(x, userData);
			n = n.next;
		}
	}
	
	/**
	 * Sends a message <code>x</code> to all siblings of this node.<br/>
	 * Bubbling can be aborted by calling <em>stopPropagation()</em>.
	 */
	public function slipMessage(x:String, userData:Dynamic = null):Void
	{
		var n = treeNode.prev;
		while (n != null)
		{
			var e = n.val;
			if (e._hasFlag(BIT_PENDING | BIT_COMMIT_SUICIDE))
			{
				n = n.prev;
				continue;
			}
			e._clrFlag(BIT_STOP_PROPAGATION);
			e.onMessage(x, userData);
			if (e._hasFlag(BIT_STOP_PROPAGATION)) return;
			n = n.prev;
		}
		
		n = treeNode.next;
		while (n != null)
		{
			var e = n.val;
			if (e._hasFlag(BIT_PENDING | BIT_COMMIT_SUICIDE))
			{
				n = n.next;
				continue;
			}
			e._clrFlag(BIT_STOP_PROPAGATION);
			e.onMessage(x, userData);
			if (e._hasFlag(BIT_STOP_PROPAGATION)) return;
			n = n.next;
		}
	}
	
	public function toString():String
	{
		if (format != null) return format(this);
		
		if (treeNode == null)
			return Sprintf.format('[name=%s (freed)]', [Std.string(name)]);
		
		if (priority != Limits.UINT16_MAX)
			return Sprintf.format('[name=%s #c=%d, p=%02d%s]', [Std.string(name), treeNode.numChildren(), priority, _hasFlag(BIT_PENDING) ? ' p' : '']);
		else
			return Sprintf.format('[name=%s #c=%d%s]', [Std.string(name), treeNode.numChildren(), _hasFlag(BIT_PENDING) ? ' p' : '']);
	}
	
	public function getObservable():Observable
	{
		if (_observable == null)
			_observable = new Observable(0, this);
		return _observable;
	}
	
	public function attach(o:IObserver, mask = 0):Void
	{
		getObservable().attach(o, mask);
	}
	
	public function detach(o:IObserver, mask = 0):Void
	{
		if (_observable != null) getObservable().detach(o, mask);
	}
	
	public function notify(type:Int, userData:Dynamic = null):Void
	{
		getObservable().notify(type, userData);
	}
	
	public function update(type:Int, source:IObservable, userData:Dynamic):Void {}
	
	/**
	 * Invoked by <em>free()</em> on all children,
	 * giving each one the opportunity to perform some cleanup (override for implementation).
	 */
	function onFree():Void {}
	
	/**
	 * Invoked after this entity was attached to the <code>parent</code> entity (override for implementation).
	 */
	function onAdd(parent:Entity):Void {}

	/**
	 * Invoked after an <code>ancestor</code> was added (override for implementation).
	 */
	function onAddAncestor(ancestor:Entity):Void {}
	
	/**
	 * Invoked after a <code>child</code> was added (override for implementation).
	 */
	function onAddDescendant(child:Entity):Void {}
	
	/**
	 * Invoked after an entity somewhere next to this entity was added (override for implementation).
	 */
	function onAddSibling(sibling:Entity):Void {}
	
	/**
	 * Invoked after this entity was removed from its <code>parent</code> entity (override for implementation).
	 */
	function onRemove(parent:Entity):Void {}
	
	/**
	 * Invoked after an <code>ancestor</code> was removed (override for implementation).
	 */
	function onRemoveAncestor(ancestor:Entity):Void {}
	
	/**
	 * Invoked after a <code>descendant</code> was removed (override for implementation).
	 */
	function onRemoveDescendant(descendant:Entity):Void {}
	
	/**
	 * Invoked after an entity somewhere next to this entity was removed (override for implementation).
	 */
	function onRemoveSibling(sibling:Entity):Void {}
	
	/**
	 * Updates this entity (override for implementation).
	 */
	function onAdvance(dt:Float, parent:Entity):Void {}
	
	/**
	 * Renders this entity (override for implementation).
	 */
	function onRender(alpha:Float, parent:Entity):Void {}
	
	/**
	 * Receives a <code>message</code> (override for implementation).
	 */
	function onMessage(message:String, userData:Dynamic):Void {}
	
	
	
	function _prepareAdditions():Void
	{
		//postorder: set BIT_PENDING_ADD -> BIT_PROCESS for all e in subtree
		if (_hasFlag(BIT_PENDING_ADD))
		{
			_clrFlag(BIT_PENDING_ADD);
			_setFlag(BIT_PROCESS);
		}
		var n = treeNode.children;
		while (n != null)
		{
			n.val._prepareAdditions();
			n = n.next;
		}
	}
	
	function _registerHi():Void
	{
		//bottom -> up construction
		var n = treeNode.children;
		while (n != null)
		{
			n.val._registerHi();
			n = n.next;
		}
		
		var p = treeNode.parent;
		if (p != null)
		{
			if (_hasFlag(BIT_PROCESS))
				_propagateOnAddAncestor(p.val);
			else 
			{
				if (_getFlag(BIT_PENDING | BIT_ADD_ANCESTOR) == BIT_ADD_ANCESTOR)
					_propagateOnAddAncestorBackTrack(p.val);
			}
		}
	}
	
	function _propagateOnAddAncestor(x:Entity):Void
	{
		if (_getFlag(BIT_PENDING | BIT_ADD_ANCESTOR) == BIT_ADD_ANCESTOR)
		{
			#if debug
			_stats[INDEX_ADD_ANCESTOR]++;
			_stats[INDEX_SUM]++;
			#end
			onAddAncestor(x);
		}
		
		//propagate to children?
		if (_hasFlag(BIT_ADD_ANCESTOR))
		{
			var n = treeNode.children;
			while (n != null)
			{
				var e = n.val;
				if (!e._hasFlag(BIT_PENDING))
					e._propagateOnAddAncestor(x);
				n = n.next;
			}
		}
	}
	
	function _propagateOnAddAncestorBackTrack(x:Entity):Void
	{
		if (_hasFlag(BIT_PROCESS))
		{
			_propagateOnAddAncestor(x);
			return;
		}
		var n = treeNode.children;
		while (n != null)
		{
			var e = n.val;
			if (e._getFlag(BIT_PENDING) == 0)
				e._propagateOnAddAncestorBackTrack(x);
			n = n.next;
		}
	}
	
	function _registerLo():Void
	{
		//postorder: bottom -> up construction
		var n = treeNode.children;
		while (n != null)
		{
			n.val._registerLo();
			n = n.next;
		}
		var p = treeNode.parent;
		if (p != null)
		{
			if (_getFlag(BIT_PROCESS | BIT_ADD_DESCENDANT) == (BIT_PROCESS | BIT_ADD_DESCENDANT))
				_propagateOnAddDescendant(p.val);
			else
			{
				if (_getFlag(BIT_PENDING | BIT_ADD_DESCENDANT) == BIT_ADD_DESCENDANT)
					_propagateOnAddDescendantBackTrack(p.val);
			}
		}
	}
	
	function _propagateOnAddDescendant(x:Entity):Void
	{
		if (x._getFlag(BIT_PENDING | BIT_ADD_DESCENDANT) == BIT_ADD_DESCENDANT)
		{
			#if debug
			_stats[INDEX_ADD_DESCENDANT]++;
			_stats[INDEX_SUM]++;
			#end
			x.onAddDescendant(this);
		}
		
		if (_hasFlag(BIT_ADD_DESCENDANT))
		{
			var n = treeNode.children;
			while (n != null)
			{
				var e = n.val;
				if (e._getFlag(BIT_PENDING | BIT_ADD_DESCENDANT) == BIT_ADD_DESCENDANT)
					e._propagateOnAddDescendant(x);
				n = n.next;
			}
		}
	}
	
	function _propagateOnAddDescendantBackTrack(x:Entity):Void
	{
		if (_hasFlag(BIT_PROCESS))
		{
			_propagateOnAddDescendant(x);
			return;
		}
		var n = treeNode.children;
		while (n != null)
		{
			var e = n.val;
			if (e._getFlag(BIT_PENDING | BIT_ADD_DESCENDANT) == BIT_ADD_DESCENDANT)
				e._propagateOnAddDescendantBackTrack(x);
			n = n.next;
		}
	}
	
	function _register():Void
	{
		var n = treeNode.children;
		while (n != null)
		{
			n.val._register();
			n = n.next;
		}
		if (_hasFlag(BIT_PROCESS))
		{
			var p = treeNode.parent.val;
			
			if (_hasFlag(BIT_ADD_SIBLING))
				p._propagateOnAddSibling(this);
			
			onAdd(p);
			#if debug
			_stats[INDEX_ADD]++;
			_stats[INDEX_SUM]++;
			#end
		}
		_clrFlag(BIT_PROCESS);
	}
	
	function _propagateOnAddSibling(child:Entity):Void
	{
		child._setFlag(BIT_ADDED);
		var n = treeNode.children;
		while (n != null)
		{
			var e = n.val;
			if (!e._hasFlag(BIT_ADDED))
			{
				e.onAddSibling(child);
				child.onAddSibling(e);
				#if debug
				_stats[INDEX_ADD_SIBLING]++;
				_stats[INDEX_ADD_SIBLING]++;
				_stats[INDEX_SUM]++;
				#end
			}
			n = n.next;
		}
	}
	
	function _prepareRemovals():Void
	{
		if (_hasFlag(BIT_PENDING_REMOVE))
		{
			_clrFlag(BIT_PENDING_REMOVE);
			_setFlag(BIT_PROCESS);
		}
		var n = treeNode.children;
		while (n != null)
		{
			n.val._prepareRemovals();
			n = n.next;
		}
	}
	
	function _unregister():Void
	{
		var n = treeNode.children;
		while (n != null)
		{
			n.val._unregister();
			n = n.next;
		}
		
		if (treeNode.parent == null) return;
		
		if (_hasFlag(BIT_PROCESS))
		{
			_setFlag(BIT_COMMIT_REMOVAL);
			var p = treeNode.parent.val;
			onRemove(p);
			
			if (_hasFlag(BIT_REMOVE_SIBLING))
				p._propagateOnRemoveSibling(this);
		}
	}
	
	function _propagateOnRemoveSibling(child:Entity):Void
	{
		child._setFlag(BIT_REMOVED);
		var n = treeNode.children;
		while (n != null)
		{
			var e = n.val;
			if (!e._hasFlag(BIT_REMOVED))
			{
				e.onRemoveSibling(child);
				child.onRemoveSibling(e);
				#if debug
				_stats[INDEX_REMOVE_SIBLING]++;
				_stats[INDEX_REMOVE_SIBLING]++;
				_stats[INDEX_SUM]++;
				#end
			}
			n = n.next;
		}
	}
	
	function _unregisterHi():Void
	{
		var n = treeNode.children;
		while (n != null)
		{
			n.val._unregisterHi();
			n = n.next;
		}
		var p = treeNode.parent;
		if (_hasFlag(BIT_PROCESS))
			_propagateOnRemoveAncestor(p.val);
		else
		{
			if (p == null) return;
			if (_hasFlag(BIT_PENDING)) return;
			if (treeNode.children == null) return;
			_propagateOnRemoveAncestorBackTrack(p.val);
		}
	}
	
	function _propagateOnRemoveAncestor(x:Entity):Void
	{
		if (_getFlag(BIT_PENDING | BIT_REMOVE_ANCESTOR) == BIT_REMOVE_ANCESTOR)
		{
			onRemoveAncestor(x);
			#if debug
			_stats[INDEX_REMOVE_ANCESTOR]++;
			_stats[INDEX_SUM]++;
			#end
		}
		
		//propagate to children?
		if (_hasFlag(BIT_REMOVE_ANCESTOR))
		{
			var n = treeNode.children;
			while (n != null)
			{
				var e = n.val;
				if (!e._hasFlag(BIT_PENDING))
					e._propagateOnRemoveAncestor(x);
				n = n.next;
			}
		}
	}
	
	function _propagateOnRemoveAncestorBackTrack(x:Entity):Void
	{
		if (_hasFlag(BIT_PROCESS))
		{
			_propagateOnRemoveAncestor(x);
			return;
		}
		var n = treeNode.children;
		while (n != null)
		{
			var e = n.val;
			if (e._getFlag(BIT_PENDING) == 0)
				e._propagateOnRemoveAncestorBackTrack(x);
			n = n.next;
		}
	}
	
	function _unregisterLo():Void
	{
		var n = treeNode.children;
		while (n != null)
		{
			n.val._unregisterLo();
			n = n.next;
		}
		var p = treeNode.parent;
		if (_getFlag(BIT_PROCESS | BIT_REMOVE_DESCENDANT) == (BIT_PROCESS | BIT_REMOVE_DESCENDANT))
			_propagateOnRemoveDescendant(p.val);
		else
		{
			if (p == null) return;
			if (_getFlag(BIT_PENDING | BIT_REMOVE_DESCENDANT) == BIT_PENDING) return;
			if (treeNode.children == null) return;
			_propagateOnRemoveDescendantBackTrack(p.val);
		}
	}
	
	function _propagateOnRemoveDescendant(x:Entity):Void
	{
		if (x._getFlag(BIT_PENDING | BIT_REMOVE_DESCENDANT) == BIT_REMOVE_DESCENDANT)
		{
			x.onRemoveDescendant(this);
			#if debug
			_stats[INDEX_REMOVE_DESCENDANT]++;
			_stats[INDEX_SUM]++;
			#end
		}
		
		if (_hasFlag(BIT_REMOVE_DESCENDANT))
		{
			var n = treeNode.children;
			while (n != null)
			{
				var e = n.val;
				if (e._getFlag(BIT_PENDING | BIT_REMOVE_DESCENDANT) == BIT_REMOVE_DESCENDANT)
					e._propagateOnRemoveDescendant(x);
				n = n.next;
			}
		}
	}
	
	function _propagateOnRemoveDescendantBackTrack(x:Entity):Void
	{
		if (_getFlag(BIT_PROCESS | BIT_REMOVE_DESCENDANT) == (BIT_PROCESS | BIT_REMOVE_DESCENDANT))
		{
			_propagateOnRemoveDescendant(x);
			return;
		}
		var n = treeNode.children;
		while (n != null)
		{
			var e = n.val;
			if (e._getFlag(BIT_PENDING | BIT_REMOVE_DESCENDANT) == BIT_REMOVE_DESCENDANT)
				e._propagateOnRemoveDescendantBackTrack(x);
			n = n.next;
		}
	}
	
	function _removeNodes():Void
	{
		var n = treeNode.children;
		while (n != null)
		{
			var hook = n.next;
			n.val._removeNodes();
			n = hook;
		}
		
		sortChildren();
		
		if (_hasFlag(BIT_COMMIT_REMOVAL))
		{
			treeNode.unlink();
			//recursively destroy subtree rooted at this node?
			if (_hasFlag(BIT_COMMIT_SUICIDE)) _free();
		}
		
		//clean up flags
		_clrFlag(BIT_PROCESS | BIT_COMMIT_REMOVAL | BIT_ADDED | BIT_REMOVED);
	}
	
	function _propagateAdvance(timeDelta:Float, parent:Entity):Void
	{
		#if debug
		D.assert(treeNode != null, 'treeNode != null');
		#end
		
		var n = treeNode.children;
		while (n != null)
		{
			var e = n.val;
			if (e._hasFlag(BIT_PENDING | BIT_COMMIT_SUICIDE))
			{
				n = n.next;
				continue;
			}
			e._clrFlag(BIT_STOP_PROPAGATION);
			if (e._hasFlag(BIT_ADVANCE)) e.onAdvance(timeDelta, parent);
			if (e._doSubtree()) e._propagateAdvance(timeDelta, e);
			n = n.next;
		}
	}
	
	function _propagateRender(alpha:Float, parent:Entity):Void
	{
		#if debug
		D.assert(treeNode != null, 'treeNode != null');
		#end
		
		var n = treeNode.children;
		while (n != null)
		{
			var e = n.val;
			if (e._hasFlag(BIT_PENDING | BIT_COMMIT_SUICIDE))
			{
				n = n.next;
				continue;
			}
			e._clrFlag(BIT_STOP_PROPAGATION);
			if (e._hasFlag(BIT_RENDER)) e.onRender(alpha, parent);
			if (e._doSubtree()) e._propagateRender(alpha, e);
			n = n.next;
		}
	}
	
	function _sortChildrenCompare(a:Entity, b:Entity):Int
	{
		return a.priority - b.priority;
	}
	
	function _free():Void
	{
		var tmp = treeNode;
		treeNode.postorder
		(
			function(n, u)
			{
				var e = n.val;
				if (e._observable != null)
				{
					e._observable.free();
					e._observable = null;
				}
				e._class = null;
				e.treeNode = null;
				e.onFree();
				return true;
			});
		tmp.free();
	}
	
	function _isDirty():Bool
	{
		if (_hasFlag(BIT_PENDING)) return true;
		var n = treeNode.children;
		while (n != null)
		{
			if (n.val._isDirty()) return true;
			n = n.next;
		}
		return false;
	}
	
	
	
	inline function _doSubtree():Bool
	{
		return _flags & (BIT_STOP_PROPAGATION | BIT_PROCESS_SUBTREE) == BIT_PROCESS_SUBTREE;
	}
	
	inline function _getFlag(mask:Int):Int
	{
		return _flags & mask;
	}
	
	inline function _hasFlag(mask:Int):Bool
	{
		return _flags & mask > 0;
	}
	
	inline function _setFlag(mask:Int):Void
	{
		_flags |= mask;
	}
	
	inline function _clrFlag(mask:Int):Void
	{
		_flags &= ~mask;
	}
	
	inline function _getClass():Class<Entity>
	{
		if (_class == null) _class = Type.getClass(this);
		return _class;
	}
}