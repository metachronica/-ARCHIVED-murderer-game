/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

($, get-svg, make-svg) <- define <[jquery utils/get-svg utils/make-svg]>

class LoaderView
	
	($parent, cb)!->
		
		(err, $svg) <-! get-svg \loading-screen.svg
		return cb err if err?
		
		@$parent = $parent
		@$el = $ \<div/>, class: \loader
		
		@$death = make-svg.svg!
		
		@$death .css do
			width: 3000px
			height: 3000px
		
		$ '.svgid-death', $svg .append-to @$death
		
		@$el.append @$death
		
		::attach.call @
		
		cb null, @
	
	is-attached: false
	attach: !-> @$parent.append @$el unless @is-attached
	
	destroy: (cb)!->
		void
