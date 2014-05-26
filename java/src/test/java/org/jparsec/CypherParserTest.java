package org.jparsec;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.Test;


public class CypherParserTest {

  private final CypherParser parser = new CypherParser();

  @Test
  public void parsesIdentifier() throws Exception {
    assertThat(parser.parse("joe")).isEqualTo(new Identifier("joe"));
  }

}
