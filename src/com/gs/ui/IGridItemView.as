package com.gs.ui
{
	import com.gs.utils.IItemCollection;

	public interface IGridItemView
	{
		function resize_Item(nx: Number, ny: Number, nw: Number, nh: Number): void;
		function update_Item(v: IItemCollection, id: int): void;
	}

}