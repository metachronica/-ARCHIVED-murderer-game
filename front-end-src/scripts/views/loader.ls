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
		
		(err, death) <~! svg.get \loading-screen, \death, {space: 2}
		throw err if err?
		(err, loader-bar) <~! svg.get \loading-screen, \loader-bar, {space: 2}
		throw err if err?
		(err, loading-text) <~! svg.get \loading-screen, \loading-text, {space: 2}
		throw err if err?
		
		@load-text = loading-text
		@death     = death
		@bar       = loader-bar
		
		if opts.cb?
			opts.cb.bind null, null |> set-timeout _, 0
	
	render: !->
		@$el.html @template @model
		
		@load-text |> @put-to-region \load-text
		@death     |> @put-to-region \death
		@bar       |> @put-to-region \progress-bar

{LoaderView}
