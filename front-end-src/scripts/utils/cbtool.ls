/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

prelude, Promise <- define <[ prelude promise ]>

{head, tail} = prelude

cbok = (cb)-> !->
	args = Array::slice.call arguments
	err  = args |> head
	throw err if err?
	args |> tail |> cb.apply null, _

cbcar = (car, cb)->
	<-! car
	args = Array::slice.call arguments
	err  = args |> head
	throw err if err?
	args |> tail |> cb.apply null, _

p2cb = (promise, cb) !->
	
	unless promise instanceof Promise
		err = new Error "'promise' isn't instance of Promise"
		console.error \cbtool:p2cb, err, (err.stack or null)
		throw err
	
	promise
		.then  (!-> cb.bind null, null, it |> set-timeout _, 0)
		.catch (!-> cb.bind null, it       |> set-timeout _, 0)

p2cbok = (promise, cb) !->
	
	unless promise instanceof Promise
		err = new Error "'promise' isn't instance of Promise"
		console.error \cbtool:p2cbok, err, (err.stack or null)
		throw err
	
	promise
		.then (!-> cb.bind null, it |> set-timeout _, 0)
		.catch (err)!->
			let err
				err = new Error "'err' is empty" unless err?
				console.error \cbtool:p2cbok, 'catch', err, (err.stack or null)
				throw err
			|> set-timeout _, 0

{cbok, cbcar, p2cb, p2cbok}
