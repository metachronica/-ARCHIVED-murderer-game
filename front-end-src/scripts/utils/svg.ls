/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

($, Snap, p2cb) <- define <[ jquery snap utils/p2cb ]>

{pairs-to-obj, keys, Obj} = require \prelude-ls

/**
 * resources-list :: [string]
 */
const resources-list = <[
	loading-screen
]>

const cfg = $ \html .data \cfg

resources  = {}
exceptions = {}

/**
 * Load resource as text
 *
 * load(res-name :: string) -> Promise
 */
load = (res-name)->
	
	# already loaded
	x = resources[res-name] ; return x if x?
	
	defer = $.Deferred!
	
	if (resources-list.index-of res-name) is -1
		defer.reject new exceptions.ResourceNotFound null, res-name
	else
		$.ajax do
			url: "#{cfg.static-dir}/images/#{res-name}.svg"
			method: \GET
			data-type: \text
		.then (data)!->
			defer.resolve data
		, (xhr, text-status, err-thrown)!->
			defer.reject \
				new exceptions.ResourceLoadError null, res-name, err-thrown
	
	resources[res-name] = defer

/**
 * Get element from resource
 *
 * get(res-name :: string, el-id :: string) -> Snap
 */
get = (res-name, el-id, {space=1}, cb)-->
	
	(err, data) <-! p2cb load res-name
	return cb err if err?
	
	f = data |> Snap.parse
	
	el = f.select "##{el-id}"
	unless el?
		return cb new exceptions.ElementNotFound null, res-name, el-id
	
	clone = Snap!
	clone.append el
	target = clone.select "##{el-id}"
	bbox = target.get-b-box!
	
	<[ width height ]>
	|> ( .map -> [it, bbox[it]] )
	|> pairs-to-obj
	|> Obj.map (+ space * 2)
	|> Obj.map Math.round
	|> clone.attr
	
	target.attr transform: "T-#{bbox.x - space},-#{bbox.y - space}"
	
	cb null, clone

/**
 * Load all resources (useful for preloading)
 *
 * every-cb(
 *   loaded-count :: number
 *   total-count  :: number
 * )
 *
 * load-all(every-cb :: Function) -> Promise
 */
load-all = (every-cb)->
	
	promises = resources-list.map load
	
	staph        = no
	loaded-count = 0
	
	promises.for-each (item)!->
		
		(err) <-! p2cb item
		return staph := yes if staph or err?
		
		loaded-count += 1
		every-cb loaded-count, promises.length
	
	# wait for all promises
	$.when.apply null, promises

exceptions.ResourceNotFound = class extends Error
	(message, res-name) !->
		super!
		(x = res-name ; @resource-name = x if x?)
		if message?
			@message = message
		else
			@message = "
				Resource not found
				#{x = res-name ; if x? then " by name '#{x}'" else ''}
			"

exceptions.ResourceLoadError = class extends Error
	(message, res-name, err-text) !->
		super!
		(x = res-name ; @resource-name = x if x?)
		(x = err-text ; @error-text = x.to-string! if x?)
		if message?
			@message = message
		else
			@message = "
				Resource load error
				#{x = err-text ; if x? then " (message: '#{x}')" else ''}
				#{x = res-name ; if x? then " by name '#{x}'" else ''}
			"

exceptions.ElementNotFound = class extends Error
	(message, res-name, el-id) !->
		super!
		(x = res-name ; @resource-name = x if x?)
		(x = el-id ; @element-id = x.to-string! if x?)
		if message?
			@message = message
		else
			@message = "
				Element
				#{x = el-id ; if x? then " by id '#{x}'" else ''}
				\ of resource
				#{x = res-name ; if x? then " by name '#{x}'" else ''}
				\ not found
			"

# exceptions names
exceptions |> keys |> ( .for-each !-> exceptions[it]::name = it )

{get, load, load-all, exceptions}
