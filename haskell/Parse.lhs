Classical derivation of (a small fraction of) monadic
parser combinators from the ground-up

This is Completely stolen from:
 - http://www.cs.nott.ac.uk/~gmh/pearl.pdf.

An efficient implementation can be found in:
 - http://legacy.cs.uu.nl/daan/download/papers/parsec-paper.pdf

First some technicalities from Haskell...

> module Parse where
> import Data.List(isPrefixOf,stripPrefix)
> import Data.Maybe(fromJust)
> import Data.Char(isAlpha,isDigit)






The type of parsers

A parser for anytype `a` is simply a function that takes as input
a string and returns either some result, along with non-consumed
input, or nothing.

> newtype Parser a = P { runParser :: String -> Result a }
> 
> data Result a = Ok a String
>               | Fail
>               deriving (Eq,Show)
>                        







One of the simplest parsers that can be defined is a parser for
a single character which returns the matched character if it is found
in the input string along with the tail of the list.

> char :: Char -> Parser Char
> char c = P char'
>   where
>     char' (x:xs) | x == c = Ok x xs
>     char'  _             = Fail







Given we are working with plain functions, we can expand on parsing
a character to a characted matching a predicate:

> satisfy :: (Char -> Bool) -> Parser Char
> satisfy p = P char'
>     where
>       char'(c:cs) | p c = Ok c cs
>                   | otherwise = Fail

This allows us to define parsers for class of characters:

> alpha :: Parser Char
> alpha = satisfy isAlpha
> 
> digit :: Parser Char
> digit = satisfy isDigit



Things start to become interesting when we want to combine parsers,
giving rise to more complex objects.
A first way to combine parsers is to *sequence* them in such a way
that second parser parses what remains from first parser,
possibly using the returned value of the first parser in the process
and itself returning some result.

> followedBy :: Parser a -> (a -> Parser b) -> Parser b
> followedBy p f = P (\ input -> case runParser p input of
>                        Fail      -> Fail
>                        Ok a rest -> runParser (f a) rest)







It turns that if we define another function returning a constant
value, this function and  `followedBy` makes `Parser a` a *monad*
which is an important concept in functional programming

> instance Monad Parser where
>   return x = P (\ input -> Ok x input)
>   (>>=)    = followedBy











Among other benefits, monadic style gives us
the ability to write sequences in a more "natural" way
using special do-notation:

> twochars :: Char -> Char -> Parser String
> twochars c c' = do
>   s <- char c
>   s'<- char c'
>   return $ [s,s']









Another interesting way to combine parsers is the *alternative*: The result of combining two parsers with an `or` combinator is the
first result that matches:

> (<|>) :: Parser a -> Parser a -> Parser a
> p <|> q = P (\ input -> case runParser p input of
>                 Fail -> runParser q input
>                 r    -> r)









Given sequence, unit (return) and alternative, we can define more
complex parsers out of the simple `char` parser or for that matter
out of any simpler parser

> many1 :: Parser a -> Parser [a]
> many1 p = do
>   r  <- p
>   rs <- many p
>   return $ r:rs

> many :: Parser a -> Parser [a]
> many p = P (many' [])
>   where
>     many' acc input  = case runParser p input of
>       Ok a rest -> many' (a:acc) rest
>       Fail      -> Ok acc input


