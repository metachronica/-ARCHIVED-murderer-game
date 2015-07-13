/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

(
	$, basic-view, templates
) <- define <[
	jquery views/basic utils/templates
]>

{BasicView} = basic-view

class LoaderView extends BasicView
	
	class-name: \loader
	
	template: templates.loader
	
	svg-resources:
		loading-screen:
			death: {space: 2}
			loader-bar: {space: 2}
			loading-text: {space: 2}
	
	initialize: (opts)!->
		super ...
		
		<~! @load-svg-resources
		
		@load-text = @svg.loading-screen.loading-text
		@death     = @svg.loading-screen.death
		@bar       = @svg.loading-screen.loader-bar
		
		@progress  = @bar.select \#loader-front
		
		(opts.cb.bind null, null |> set-timeout _, 0) if opts.cb?
	
	render: !->
		@$el.html @template @model
		
		@load-text |> @put-to-region \load-text
		@death     |> @put-to-region \death
		@bar       |> @put-to-region \progress-bar

{LoaderView}
