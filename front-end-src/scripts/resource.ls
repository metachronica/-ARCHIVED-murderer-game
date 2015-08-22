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

{map, pairs-to-obj, keys, Obj} = prelude
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
load = (res-name)->
	
	# already loaded
	x = resources[res-name] ; return x if x?
	
	resources[res-name] = new Promise !(resolve, reject)->
		$.ajax do
			url: "#{cfg.static-dir}/images/#{res-name}.svg"
			method: \GET
			data-type: \text
			success: (data)!-> resolve data
			error: !->
				msg = "Load resource '#{res-name}' error"
				console.error msg
				reject msg

/**
 * Get element from resource.
 *
 * get(res-name :: string, el-id :: string, [space :: number])
 */
get = (res-name, el-id, {space=2})-->
	
	resolve, reject <-! new Promise _
	
	err, data <-! p2cb load res-name
	if err?
		reject err
		return
	
	try
		f = data |> Snap.parse
	catch
		reject e
		return
	
	try
		el = f.select "##{el-id}"
	catch
		reject e
		return
	
	unless el?
		reject new Error "Element '##{el-id}' not found in resourse '#{res-name}'"
		return
	
	clone = Snap!
	clone.append el
	target = clone.select "##{el-id}"
	bbox = target.get-b-box!
	
	<[ width height ]>
		|> map (-> [it, bbox[it]])
		|> pairs-to-obj
		|> Obj.map (+ space * 2)
		|> Obj.map Math.round
		|> clone.attr
	
	target.attr transform: "T-#{bbox.x - space},-#{bbox.y - space}"
	
	resolve clone

{load, get}
