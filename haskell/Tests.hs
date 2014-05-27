module Tests where
import           Parse
import           Prelude    hiding (or)
import           Test.HUnit

parse_single_string = TestList [
  runParser (char 'f') "foo"  ~?= Ok 'f' "oo"
  , runParser (char 'f') "bar" ~?= Fail
  ]

parse_two_characters = TestList [
  runParser (twochars 'f' 'o') "foo" ~?= Ok "fo" "o"
  , runParser (twochars 'f' 'o') "bar" ~?= Fail
    ]

parse_one_char_or_the_other =
  runParser (char 'f' <|> char 'o') "oof" ~?= Ok 'o' "of"

parse_several_chars = TestList [
  runParser (many1 $ char 'a') "aaaabb" ~?= Ok "aaaa" "bb"
  , runParser (many1 $ char 'a') "bbbbb"  ~?= Fail
    ]

identifier :: Parser String
identifier = many1 (alpha <|> digit)

parse_alphanum_identifier =
  runParser identifier "foo baz" ~?= Ok "foo" " baz"

tests :: Test
tests = TestList [
  parse_single_string
  , parse_two_characters
  , parse_one_char_or_the_other
  , parse_several_chars
  , parse_alphanum_identifier
  ]
