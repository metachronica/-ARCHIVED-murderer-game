/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

require! {
	path
	\./v : {revision}
}

traits = {
	revision
	static-file: (file)->
		while (file.char-at 0) is '/'
			file = file.slice 1
		"#{path.join \/static, file}?v=#{revision}"
}

export get = -> {} <<< traits
