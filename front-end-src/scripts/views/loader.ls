/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

(
	$, B, Snap, async
	basic-view
	templates, svg, cbtool
) <- define <[
	jquery backbone snap async
	views/basic
	utils/templates utils/svg utils/cbtool
]>

{cbcar} = cbtool
{camelize, pairs-to-obj, Obj} = require \prelude-ls

{BasicView} = basic-view

class LoaderView extends BasicView
	
	class-name: \loader
	
	template: templates.loader
	
	initialize: (opts)!->
		super ...
		
		res = svg.get \loading-screen
		
		resources =
			<[ death loader-bar loading-text ]>
			|> ( .map -> [it |> camelize, res it, {space: 2}] )
			|> pairs-to-obj
			|> Obj.map (car)-> (cb)!-> car cb
		
		par = (arr, cb)--> async.parallel arr, cb
		(r) <~! cbcar par resources
		
		@load-text = r.loading-text
		@death     = r.death
		@bar       = r.loader-bar
		
		@progress  = @bar.select \#loader-front
		
		if opts.cb?
			opts.cb.bind null, null |> set-timeout _, 0
	
	render: !->
		@$el.html @template @model
		
		@load-text |> @put-to-region \load-text
		@death     |> @put-to-region \death
		@bar       |> @put-to-region \progress-bar

{LoaderView}
