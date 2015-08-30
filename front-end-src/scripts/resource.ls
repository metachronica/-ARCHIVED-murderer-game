/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

(
	prelude
	$
	Snap
	Promise
	cbtool
	cfg
) <- define <[
	prelude
	jquery
	snap
	promise
	cbtool
	cfg
]>

{map, pairs-to-obj, keys, Obj, Func} = prelude
{p2cb} = cbtool

/**
 * Resources cache.
 *
 * Object.<Promise>
 */
resources = {}

/**
 * Load resource contents.
 *
 * load(res-name :: string) -> Promise
 */
load = (res-name) ->
	resources[res-name] = new Promise (resolve, reject) !->
		$.ajax do
			url: "#{cfg.static-dir}/images/#{res-name}.svg"
			method: \GET
			data-type: \text
			success: (data) !-> resolve data
			error: !->
				msg = "Load resource '#{res-name}' error"
				console.error msg
				reject msg
load |>= Func.memoize # return cached promise if already loaded

/**
 * Get element from resource.
 *
 * get(res-name :: string, el-id :: string, [offset :: number])
 */
get = (
	res-name,
	el-id,
	{
		offset   = 2
		
		offset-x = null
		offset-y = null
		
		offset-l = null
		offset-r = null
		offset-t = null
		offset-b = null
	}
) -->
	
	offset-l ?= offset-x ? offset
	offset-r ?= offset-x ? offset
	offset-t ?= offset-y ? offset
	offset-b ?= offset-y ? offset
	
	resolve, reject <-! new Promise _
	
	err, data <-! p2cb load res-name
	if err?
		reject err
		return
	
	# parse text of SVG file by Snap
	try
		f = data |> Snap.parse
	catch
		reject e
		return
	
	# find element of resource
	try
		el = f.select "##{el-id}"
	catch
		reject e
		return
	
	unless el?
		reject new Error "
			Element '##{el-id}' not found in resourse '#{res-name}'
		"
		return
	
	clone = Snap!
	clone.append el
	target = clone.select "##{el-id}"
	bbox = target.get-b-box!
	
	<[ width height ]>
		|> map (it)->
			[it].concat [
				bbox[it] + switch it
				| \width  => offset-l + offset-r
				| \height => offset-t + offset-b
				| _       => ...
				|> Math.round
			]
		|> pairs-to-obj
		|> clone.attr
	
	matrix = new Snap.Matrix
	matrix.translate -(bbox.x - offset-l), -(bbox.y - offset-t)
	target.transform matrix
	
	resolve clone

{load, get}
