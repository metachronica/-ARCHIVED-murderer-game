/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

(
	$, B, Snap
	basic-view
	templates, svg, cbtool
) <- define <[
	jquery backbone snap
	views/basic
	utils/templates utils/svg utils/cbtool
]>

{cbcar} = cbtool

{BasicView} = basic-view

class LoaderView extends BasicView
	
	class-name: \loader
	
	template: templates.loader
	
	initialize: (opts)!->
		super ...
		
		res = svg.get \loading-screen
		
		( death        ) <~! cbcar res \death        , {space: 2}
		( loader-bar   ) <~! cbcar res \loader-bar   , {space: 2}
		( loading-text ) <~! cbcar res \loading-text , {space: 2}
		
		@load-text = loading-text
		@death     = death
		@bar       = loader-bar
		
		@progress  = @bar.select \#loader-front
		
		if opts.cb?
			opts.cb.bind null, null |> set-timeout _, 0
	
	render: !->
		@$el.html @template @model
		
		@load-text |> @put-to-region \load-text
		@death     |> @put-to-region \death
		@bar       |> @put-to-region \progress-bar

{LoaderView}
