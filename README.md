# nurby
Not cURl w/ ruBY

A curl-like Ruby app that adds missing features and allows Ruby injection (not meant as a curl replacement).

This program is still currently in development on v0.5.0.  The first working version will be v1.0.0.

Goals for the project:

```
"bb.com/[05-] bb [u=1-4][l=1-8/u].pdf"

"eu.com/[n=01-74]" -o "[n] eu [u=1-4][l=1-4/u]#{rb:1:r}[s=1-2/l].pdf"
--out-method "r:i(2,'u','l'); e('{R*2}'); if v('u')%2 == 0 && v('l')%4 == 0 && v('s') == 2"

-o --out-file
-w --out-method
-m --in-method
-x (disable "#{}")

{} = set
[] = range

#{rb:1:r}
#{ruby::method}
-1 = at beginning
 0 = current place
 1 = at end
:: = default to 1

rb = ruby alias
i  = ignore(num_of_times,*var_ids)
e  = eval(nurby_exp_str)

[l=1-8/u*2]
{s=one,two/l*2}

\{,\[,\# can all be escaped
```

## License
> nurby (https://github.com/esotericpig/nurby)  
> Copyright (c) 2017 Jonathan Bradley Whited (@esotericpig)  
> 
> nurby is free software: you can redistribute it and/or modify  
> it under the terms of the GNU Lesser General Public License as published by  
> the Free Software Foundation, either version 3 of the License, or  
> (at your option) any later version.  
> 
> nurby is distributed in the hope that it will be useful,  
> but WITHOUT ANY WARRANTY; without even the implied warranty of  
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
> GNU Lesser General Public License for more details.  
> 
> You should have received a copy of the GNU Lesser General Public License  
> along with nurby.  If not, see <http://www.gnu.org/licenses/>.  
