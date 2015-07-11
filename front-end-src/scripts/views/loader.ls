/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

(
	$, B, Snap, basic-view, templates, svg, p2cb
) <- define <[
	jquery backbone snap views/basic utils/templates utils/svg utils/p2cb
]>

{BasicView} = basic-view

class LoaderView extends BasicView
	
	class-name: \loader
	
	template: templates.loader
	
	initialize: (opts)!->
		super ...
		
		(err, el) <~! p2cb svg.get \loading-screen, \death, {space: 2}
		throw err if err?
		
		@death = el
		
		opts.cb?!
	
	render: !->
		@$el.html @template @model
		@death.append-to <| @$el.find \.death .get 0

{LoaderView}
