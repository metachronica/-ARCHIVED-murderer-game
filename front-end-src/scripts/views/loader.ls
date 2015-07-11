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
		
		# FIXME prevent removing element from original document
		(err, el) <~! svg.get \loading-screen, \death, {space: 2}
		throw err if err?
		
		@death = el
		
		#svg.load \loading-screen .then (!->
		#	console.log \kek
		#	window.x = it.node.child-nodes.2
		#), !->
		#	console.error \fail, it
		
		if opts.cb?
			opts.cb.bind null, null |> set-timeout _, 0
	
	render: !->
		@$el.html @template @model
		@death.append-to <| @$el.find \.death .get 0

{LoaderView}
