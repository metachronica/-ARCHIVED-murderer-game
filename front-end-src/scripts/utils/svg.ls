/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

($, Snap, p2cb) <- define <[ jquery snap utils/p2cb ]>

/**
 * @private
 * @type {[string]}
 */
const resources-list = <[
	loading-screen
]>

const cfg = $ \html .data \cfg

resources  = {}
exceptions = {}

/**
 * Load resource
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
			defer.resolve Snap.parse data
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
	
	(err, f) <-! p2cb load res-name
	return cb err if err?
	
	el = f.select "##{el-id}"
	unless el?
		return cb new exceptions.ElementNotFound null, res-name, el-id
	
	clone = Snap!
	clone.append el
	target = clone.select "##{el-id}"
	bbox = target.get-b-box!
	
	clone.attr <[ width height ]>.reduce ((attr, key)->
		attr[key] = bbox[key] + (space*2)
		attr
	), {}
	
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
		item.then !->
			return if staph
			loaded-count += 1
			every-cb loaded-count, promises.length
		, !->
			staph := yes
	
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
Object.keys exceptions .for-each !-> exceptions[it]::name = it

{get, load, load-all, exceptions}
