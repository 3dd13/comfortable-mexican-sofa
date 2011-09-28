require File.expand_path('../../test_helper', File.dirname(__FILE__))

class PageFileTagTest < ActiveSupport::TestCase
  
  def test_initialize_tag
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(
      cms_pages(:default), '{{ cms:page_file:label }}'
    )
    assert 'url', tag.type
    
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(
      cms_pages(:default), '{{ cms:page_file:label:partial }}'
    )
    assert 'partial', tag.type
  end
  
  def test_initialize_tag_failure
    [
      '{{cms:page_file}}',
      '{{cms:not_page_file:label}}',
      '{not_a_tag}'
    ].each do |tag_signature|
      assert_nil ComfortableMexicanSofa::Tag::PageFile.initialize_tag(
        cms_pages(:default), tag_signature
      )
    end
  end
  
  def test_content_and_render
    page = cms_pages(:default)
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(
      page, '{{ cms:page_file:file }}'
    )
    assert_equal nil, tag.content
    assert_equal '', tag.render
    
    page.update_attributes!(
      :blocks_attributes => [
        { :label    => 'file',
          :content  => fixture_file_upload('files/valid_image.jpg') }
      ]
    )
    file = tag.block.files.first
    timestamp = file.updated_at.to_f.to_i
    
    assert_equal file, tag.content
    assert_equal "/system/files/#{file.id}/original/valid_image.jpg?#{timestamp}", tag.render
    
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(page, '{{ cms:page_file:file:link }}')
    assert_equal "<a href='/system/files/#{file.id}/original/valid_image.jpg?#{timestamp}' target='_blank'>file</a>", 
      tag.render
      
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(page, '{{ cms:page_file:file:link:link label }}')
    assert_equal "<a href='/system/files/#{file.id}/original/valid_image.jpg?#{timestamp}' target='_blank'>link label</a>", 
      tag.render
      
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(page, '{{ cms:page_file:file:image }}')
    assert_equal "<img src='/system/files/#{file.id}/original/valid_image.jpg?#{timestamp}' alt='file' />", 
      tag.render
      
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(page, '{{ cms:page_file:file:image:image alt }}')
    assert_equal "<img src='/system/files/#{file.id}/original/valid_image.jpg?#{timestamp}' alt='image alt' />", 
      tag.render
      
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(page, '{{ cms:page_file:file:partial }}')
    assert_equal "<%= render :partial => 'partials/page_file', :locals => {:identifier => #{file.id}} %>", 
      tag.render
      
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(page, '{{ cms:page_file:file:partial:path/to/partial }}')
    assert_equal "<%= render :partial => 'path/to/partial', :locals => {:identifier => #{file.id}} %>", 
      tag.render
      
    assert tag = ComfortableMexicanSofa::Tag::PageFile.initialize_tag(page, '{{ cms:page_file:file:partial:path/to/partial:a:b }}')
    assert_equal "<%= render :partial => 'path/to/partial', :locals => {:identifier => #{file.id}, :param_1 => 'a', :param_2 => 'b'} %>", 
      tag.render
  end
  
end