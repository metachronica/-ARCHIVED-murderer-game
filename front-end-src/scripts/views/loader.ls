/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

(
	$, B, Snap, basic-view, templates, svg
) <- define <[
	jquery backbone snap views/basic utils/templates utils/svg
]>

{BasicView} = basic-view

class LoaderView extends BasicView
	
	class-name: \loader
	
	template: templates.loader
	
	initialize: (opts)!->
		super ...
		
		cfg = $ \html .data \cfg
		
		(f) <~! Snap.load "#{cfg.static-dir}/images/loading-screen.svg"
		
		death-src = f.select \#death
		
		@death = Snap!
		@death.append death-src
		death-el = @death.select \#death
		death-el-bbox = death-el.get-b-box!
		
		@death.attr do
			width: death-el-bbox.width + 4
			height: death-el-bbox.height + 4
		
		death-el.attr transform: "T-#{death-el-bbox.x-2},-#{death-el-bbox.y-2}"
		
		opts.cb?!
	
	render: !->
		@$el.html @template @model
		@death.append-to <| @$el.find \.death .get 0

{LoaderView}
