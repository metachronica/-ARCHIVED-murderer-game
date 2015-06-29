/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

require! {
	path
	\./v
}

traits =
	static-file: (file)->
		while (file.char-at 0) is '/'
			file = file.slice 1
		"#{path.join \/static, file}?v=#{123}"

export get = -> {} <<< traits
