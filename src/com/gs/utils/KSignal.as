package com.gs.utils
{
	public class KSignal
	{
		protected var fn_: Vector.<Function> = new Vector.<Function>();
		protected var fn_temp_: Vector.<Function> = new Vector.<Function>();
		protected var used_: int = 0;
		protected var on_fire_: Boolean;

		//protected var id_: Vector.<String> = new Vector.<String>();

		public function KSignal()
		{}

		/*
		 * add once
		*/
		public function add(fn: Function/*, id: String*/): void
		{
			if (fn_.indexOf(fn) < 0)
			{
				//id_[used_] = id;
				fn_[used_++] = fn;//:push-alike
			}
		}

		/*
		 * remove if have
		 */
		public function remove(fn: Function): void
		{
			var i: int = fn_.indexOf(fn);
			if (i >= 0)
			{//:swap with last.. may cause re-order.. beware..
				fn_[i] = fn_[--used_];
				//id_[i] = id_[used_];
				//id_[used_] = null;
				fn_[used_] = null;
			}
		}

		public function dispose(): void
		{
			if (fn_ != null)
			{
				fn_.length = 0;
				fn_ = null;
			}
			if (fn_temp_ != null)
			{
				fn_temp_.length = 0;
				fn_temp_ = null;
			}
			//if (id_ != null)
			//{
				//id_.length = 0;
				//id_ = null;
			//}
		}

		public function get used(): int
		{
			return used_;
		}

		public function fire(): void
		{
			if (on_fire_)
				return;
			on_fire_ = true;
			var count: int = used_;
			var i: int;
			var fn: Function;
			for (i = 0; i < count; ++i)
			{//:make copy
				fn = fn_[i] as Function;
				fn_temp_[i] = fn;
			}
			for (i = 0; i < count; ++i)
			{
				fn = fn_temp_[i] as Function;
				fn();//:may call add/remove
			}
			on_fire_ = false;
		}

		public function fire_Ex(...argv): void
		{
			if (on_fire_)
				return;
			on_fire_ = true;
			var count: int = used_;
			var i: int;
			var fn: Function;
			for (i = 0; i < count; ++i)
			{//:make copy
				fn = fn_[i] as Function;
				fn_temp_[i] = fn;
			}
			for (i = 0; i < count; ++i)
			{
				fn = fn_temp_[i] as Function;
				execute(fn, argv);//:may call add/remove
			}
			on_fire_ = false;
		}

		protected function execute(fn: Function, argv: Array): void
		{
			//:NOTE: simple ifs are faster than switch: http://jacksondunstan.com/articles/1007
			var argc: int = argv.length;
			var paramc: int = fn.length;
			if (paramc < argc)
				argc = paramc;//:?TODO review
			if (argc == 0)
				fn();
			else if (argc == 1)
				fn(argv[0]);
			else if (argc == 2)
				fn(argv[0], argv[1]);
			else if (argc == 3)
				fn(argv[0], argv[1], argv[2]);
			else
				fn.apply(null, argv);
		}

	}
}
