/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

($, snap, List) <- define <[jquery snap List]>

/**
 * @private
 * @type {[string]}
 */
const resources-list = <[
	loading-screen
]>

/**
 * @private
 * @type {Object.<Object>}
 */
resources = {}

{map} = List

/**
 * @public
 * @async
 * @param {Function} cb
 */
load-resources = (cb)!->
	
	promises = resources-list.map ->
		it
	
	# wait for all promises resolve
	$.when.apply null, promises .then (cb.bind null, null), cb

/**
 * @param {string} name - Resource name (see for resources-list)
 * @returns {Object}
 * @public
 */
get = (name)-> void

#defers = [1 to 10].map (i)->
#	defer = $.Deferred!
#	set-timeout _, i*1000 <| !->
#		console.log \dmap, i
#		if i is 5
#			defer.reject new Error \fak
#		else
#			defer.resolve!
#	defer
#
#xx = (err, results)!->
#
#	if err?
#		console.error \FAK, err
#		throw err
#
#	console.log \OK, results
#
#$.when.apply null, defers .then (xx.bind null, null), xx

{load-resources}
