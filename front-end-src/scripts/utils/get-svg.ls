/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

($) <- define <[jquery]>

$html = $ \html

cfg = $html.data \cfg

get-url = (file)-> "#{cfg.static-dir}/images/#{file}?v=#{cfg.revision}"

(file, cb)!->
	
	$.ajax do
		url: get-url file
		cache: off
		method: \GET
		data-type: \xml
		success: (body)!->
			
			$svg = $ body
			$svg .= find \svg
			
			$svg.find '[id]' .each !->
				$el = $ @
				$el.attr class: "svgid-#{$el.attr \id}"
				$el.remove-attr \id
			
			cb null, $svg
			
		error: (xhr, status, message)!->
			err = new Error "
				Fak. No game. No murders.
				\ Status: #{status}.
				\ Message: #{message}
			"
			console.error \get-svg, err
			console.trace \get-svg
			cb err
