/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

prelude, Promise <- define <[ prelude promise ]>

{head, tail, obj-to-pairs, keys, values, map, pairs-to-obj, zip} = prelude

# wrap callback and shift first `err` argument
# automatically errors handling
# example:
#   fs.read-file \filename, cbok (!-> console.log 'file contents', it)
cbok = (cb)-> !->
	
	args = Array::slice.call arguments
	err  = args |> head
	
	if err?
		console.error \cbtool:cbok, err, (err.stack or null)
		throw err
	
	args |> tail |> cb.apply null, _

# wrap curried function and shift first `err` argument for callback
# automatically errors handling
# currying support
# example:
#   f = (foo, bar, cb)--> cb null, {foo, bar}
#   car-f = f 10, 20
#   o <-! cbcar car-f
#   console.log \foo, o.foo
#   console.log \bar, o.bar
cbcar = (car, cb)-> car cbok cb

# wrap promise and delegate to callback
# example:
#   err, result <-! p2cb promise
#   throw err if err?
#   console.log 'promise result', result
p2cb = !(promise, cb)->
	
	unless promise instanceof Promise
		err = new Error "'promise' isn't instance of Promise"
		console.error \cbtool:p2cb, err, (err.stack or null)
		throw err
	
	promise
		.then  (!-> cb.bind null, null, it |> set-timeout _, 0)
		.catch (!-> cb.bind null, it       |> set-timeout _, 0)

# wrap promise and delegate to callback
# with first `err` argument shifted
# automatically errors handling
# example:
#   result <-! p2cbok promise
#   console.log 'promise result', result
p2cbok = !(promise, cb)->
	
	unless promise instanceof Promise
		err = new Error "'promise' isn't instance of Promise"
		console.error \cbtool:p2cbok, err, (err.stack or null)
		throw err
	
	promise
		.then (!-> cb.bind null, it |> set-timeout _, 0)
		.catch !(err)->
			let err
				err = new Error "'err' is empty" unless err?
				console.error \cbtool:p2cbok, 'catch', err, (err.stack or null)
				throw err
			|> set-timeout _, 0

# transform object of promises to promise with object result
# returns promise with key-val result object
# instead of results array by Promise.all
# example:
#   do
#     foo: promise-foo
#     bar: promise-bar
#   |> op2p
#   |> (.then \
#     (!->
#       console.log it.foo
#       console.log it.bar
#     ),
#     (!-> throw it))
op2p = (obj)->
	resolve, reject <-! new Promise _
	obj
		|> values
		|> Promise.all
		|> (.then \
			(!-> it |> zip (obj |> keys) |> pairs-to-obj |> resolve),
			reject)

# transform object of promises to callback
# example:
#   promises-obj =
#     foo: promise-foo
#     bar: promise-bar
#   err, results <-! op2cb promises-obj
#     throw err if err?
#     console.log \foo, results.foo
#     console.log \bar, results.bar
op2cb = !(obj, cb)-> obj |> op2p |> p2cb _, cb

# transform object of promises to callback
# with first `err` argument shifted
# automatically errors handling
# example:
#   promises-obj =
#     foo: promise-foo
#     bar: promise-bar
#   results <-! op2cbok promises-obj
#     console.log \foo, results.foo
#     console.log \bar, results.bar
op2cbok = !(obj, cb)-> obj |> op2p |> p2cbok _, cb

# export
{cbok, cbcar, p2cb, p2cbok, op2p, op2cb, op2cbok}
