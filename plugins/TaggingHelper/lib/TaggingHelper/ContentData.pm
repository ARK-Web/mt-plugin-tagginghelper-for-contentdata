package TaggingHelper::ContentData;
use strict;

sub match_field_types {
    my @types = (
        'single_line_text',
        'multi_line_text',
    );
    return @types;
}

sub script {
    my $script = <<'EOT';
<__trans_section component="TaggingHelper">
RegExp.escape = (function() {
    var specials = [
        '/', '.', '*', '+', '?', '|',
        '(', ')', '[', ']', '{', '}', '\\'
    ];

    sRE = new RegExp(
        '(\\' + specials.join('|\\') + ')', 'g'
    );

    return function(text) {
        return text.replace(sRE, '\\$1');
    }
})();

class TaggingHelper {
    id = '';
    tags_json = new Array();

    constructor(id, tags_json) {
        this.id = id;
        this.tags_json = tags_json;
    }
    close = function() {
        document.getElementById('tagging_helper_block' + this.id).style.display = 'none';
    }
    compareStrAscend = function(a, b) {
        return a.tag.localeCompare(b.tag);
    }
    compareByCount = function(a, b) {
        return b.count - a.count || a.tag.localeCompare(b.tag);
    }
    open = function(mode) {
        var block = document.getElementById('tagging_helper_block' + this.id);
        if (block.style.display == 'none') {
            block.style.display = 'block';
        }
        var tags = this.tags_json;
        var tagary = new Array();
        if (mode == 'abc' || mode == 'count') {
            for (var tag in tags) {
                tagary.push({
                    tag: tag,
                    count: tags[tag]
                });
            }
        }
        else {
            var body = this.getMatchFieldsTexts();
            for (var tag in tags) {
                var exp = new RegExp(RegExp.escape(tag));
                if (exp.test(body)) {
                    tagary.push({
                        tag: tag,
                        count: tags[tag]
                    });
                }
            }
        }
        if (mode == 'count')
            tagary.sort(this.compareByCount);
        else
            tagary.sort(this.compareStrAscend);

        var v = document.getElementById('tags' + this.id).value;
        var taglist = '';
        var table = document.createElement('div');
        table.className = 'taghelper-table';
        if (tagary.length > 0) {
          for (var i=0; i< tagary.length; i++) {
            var tag = tagary[i].tag;
            var e = document.createElement('span');
            e.onclick = this.action.bind(this);
            e.th_tag = tag;
            e.appendChild( document.createTextNode(tag) );
            var exp = new RegExp("^(.*, ?)?" + RegExp.escape(tag) + "( ?\,.*)?$");
            e.className = (exp.test(v)) ? 'taghelper_tag_selected' : 'taghelper_tag';
            table.appendChild(e);
            table.appendChild( document.createTextNode(' ') );
          }
        } else {
            var e = document.createElement('span');
            e.appendChild( document.createTextNode('<__trans phrase="No data">') );
            table.appendChild(e);
            table.appendChild( document.createTextNode(' ') );
        }

        while (block.childNodes.length) block.removeChild(block.childNodes.item(0));
        block.appendChild(table);
    }
    action = function(evt) {
        // IE-Firefox compatible
        var e = evt || window.event;
        var a = e.target || e.srcElement;
        var s = a.th_tag;
    
        var v = document.getElementById('tags' + this.id).value;
        var exp = new RegExp("^(.*, ?)?" + RegExp.escape(s) + "( ?\,.*)?$");
        if (exp.test(v)) {
            v = v.replace(exp, "$1$2");
            if (tag_delim == ',') {
                v = v.replace(/ *, *, */g, ', ');
            }
            else {
                v = v.replace(/  +/g, ' ');
            }
            a.className = 'taghelper_tag';
        }
        else {
            v += (tag_delim == ',' ? ', ' : ' ') + s;
            a.className = 'taghelper_tag_selected';
        }
        v = v.replace(/^[ \,]+/, '');
        v = v.replace(/[ \,]+$/, '');
        document.getElementById('tags' + this.id).value = v;
    }
    getMatchFieldsTexts = function() {
        var text = "";
        jQuery(taggingHelperMatchFieldIds).each(function() {
            if (this.type == 'single_line_text') {
                text += jQuery('input[name="content-field-'+ this.id +'"]').val();
            }
            else if (this.type == 'multi_line_text') {
                text += jQuery('textarea[name="content-field-'+ this.id +'"]').val();
            }
            text += "\n";
        });
        return text;
    }
}
</__trans_section>
EOT

    return $script;
}

sub _build_tag_html {
    my $html = <<'EOT';
<__trans_section component="TaggingHelper">
<script>
var tag_delim = '<mt:var name="tag_delim">';
</script>

<div class="tagging_helper_container" id="tagging_helper_container<mt:var name="content_field_id" escape="html">">
    <span 
        id="taghelper_abc<mt:var name="content_field_id" escape="html">" 
        onclick="taggingHelper<mt:var name="content_field_id" escape="html">.open('abc')" 
        class="taghelper_command"
    ><MT_TRANS phrase="alphabetical"></span>
    <span 
        id="taghelper_count<mt:var name="content_field_id" escape="html">" 
        onclick="taggingHelper<mt:var name="content_field_id" escape="html">.open('count')" 
        class="taghelper_command"
    ><MT_TRANS phrase="frequency"></span>
    <span id="taghelper_match<mt:var name="content_field_id" escape="html">" 
        onclick="taggingHelper<mt:var name="content_field_id" escape="html">.open('match')" 
        class="taghelper_command taghelper_match"
    ><MT_TRANS phrase="match in text fields"></span>
    <span 
        id="taghelper_close<mt:var name="content_field_id" escape="html">" 
        onclick="taggingHelper<mt:var name="content_field_id" escape="html">.close()" 
        class="taghelper_command"
    ><MT_TRANS phrase="close"></span>
    <div class="tagging_helper_block" id="tagging_helper_block<mt:var name="content_field_id" escape="html">" style="display: none;"></div>
</div>
</__trans_section>
EOT

    return $html;
}

sub template_source_edit_content_data {
    my ($eh, $app, $tmpl_ref) = @_;

    my $mtml = <<'EOT';
<mt:setvarblock name="css_include" append="1">
<link rel="stylesheet" href="<mt:var name="static_uri">plugins/TaggingHelper/tagging-helper.css" type="text/css">
</mt:setvarblock>
EOT

    $$tmpl_ref = $mtml . $$tmpl_ref;
}

sub template_param_edit_content_data {
    my ($eh, $app, $param, $tmpl) = @_;

    # get content_type
    my $content_type;
    my $content_type_id = $app->param('content_type_id');
    if ($content_type_id) {
        $content_type = MT::ContentType->load($content_type_id);
    } else {
        my $cd_id = $app->param('id');
        die unless $cd_id;
        my $cd = MT::ContentData->load($cd_id);
        die unless $cd;
        $content_type = $cd->content_type;
    }
    die unless $content_type;

    # content fields
    my @cfs = @{ $content_type->fields };
    die unless @cfs;

    # plugin setting
    my $plugin = MT->component('TaggingHelper');
    my $content_data_tag_target = $plugin->get_config_value('content_data_tag_target');

    my $script_tmpl = <<'EOT';
var tags_json__%ID%__ = __%tags_json%__;
var taggingHelper__%ID%__ = new TaggingHelper('__%ID%__', tags_json__%ID%__);
EOT

    my $js = script();

    my @match_field_types = match_field_types();
    my @match_field_ids;
    my $tags = get_tags();

    foreach my $cf (@cfs) {
        my $cf_id = $cf->{id} || $cf->{content_field_id};

        # pickup match fields
        if (grep { $_ eq $cf->{type} } @match_field_types) {
            push @match_field_ids, {
                id => $cf_id,
                type => $cf->{type},
            };
        }

        next unless $cf->{type} eq 'tags';

        # get tags
        if ($content_data_tag_target eq "same_field") {
            $tags = get_tags($cf);
        }
        my $tags_json = MT::Util::to_json($tags);

        # replace tmpl
        my $script = $script_tmpl;
        $script =~ s/__%ID%__/$cf_id/g;
        $script =~ s/__%tags_json%__/$tags_json/g;

        $js .= $script;
    }

    $js .= "var taggingHelperMatchFieldIds = ". MT::Util::to_json(\@match_field_ids) .";\n";

    $param->{js_include} .= "<script>\n". $js . "</script>\n";
}

sub get_tags {
    my ($cf) = @_;

    my %terms;
    if ($cf) {
        $terms{cf_id} = $cf->{content_field_id};
    }
    my $iter = MT->model('objecttag')->count_group_by(
        \%terms,
        {    sort        => 'cnt',
            direction    => 'ascend',
            group        => ['tag_id'],
        },
    );
    my %tag_counts;
    while ( my ( $cnt, $id ) = $iter->() ) {
        $tag_counts{$id} = $cnt;
    }
    my %tags = map { $_->name => $tag_counts{ $_->id } } MT->model('tag')->load({ id => [ keys %tag_counts ] });

    return \%tags;
}

sub template_source_field_html_tags {
    my ($eh, $app, $tmpl_ref) = @_;

    $$tmpl_ref .= _build_tag_html();
}

1;
