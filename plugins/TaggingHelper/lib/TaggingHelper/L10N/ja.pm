# $Id$

package TaggingHelper::L10N::ja;

use strict;
use base 'TaggingHelper::L10N::en_us';
use vars qw( %Lexicon );

## The following is the translation table.

%Lexicon = (
    'description of TaggingHelper' => '記事・ウェブページ・コンテンツデータ編集画面にタグ一覧を表示します。',
    'alphabetical' => 'ABC順',
    'frequency'    => '利用頻度順',
    'match in body' => '本文に一致',
    'match in text fields' => '他のテキスト項目に一致',
    'Content data tag target' => 'コンテンツデータのタグ候補',
    'All sites tags' => 'タグ入力欄の下に「全サイト」の「記事」「ウェブページ」「コンテンツデータ」に設定してあるタグが全て候補として表示される。',
    'Same field tags' => '自分と同じタグフィールドに設定してあるタグのみ候補として表示される。',
    'No data' => 'タグ候補はありません。',
);

1;
