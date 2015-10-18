--- 
title: My first iPhone App - Part 5
layout: post
---

_See [Part 1][part1], [Part 2][part2], [Part 3][part3], and [Part 4][part4] first_

I've been working on the app more than my recent lack of blog entries indicates.  At this point, I have what could roughly be called a beta version; almost all the features are there, and things seem to be generally working pretty well.  

## User Experience

The biggest change in the UX is the ability to add tasting notes, date tasted, and location tasted.  This is a new screen accessible from the main entry screen.  The most obvious way to do this in my mind, was a big button at the bottom:

![New Add Screen](/images/wine_brain_new_wine_5.jpg)

In designing the new screen, 
the "where tasted" and "when tasted" were straightforward; I used stock controls.  For the tasting notes, I needed a <code>UITextView</code>, which is akin to an HTML <code>TEXTAREA</code>.  The visual appearance of this control is pretty lacking compared to the <code>UITextField</code>; there is no nice beveled edge, no rounded corners, and no placeholder text.  I really just wanted a multi-line field much like the <code>UITextField</code>, but there is nothing available to create that.

So, I hacked something together.

An option for the <code>UITextField</code>'s appearance is to have a beveled edge with square corners.  In this configuration, you can adjust the height of the text field.  So, I placed such a field on the screen and sized it about the size of my tasting notes field and made the background color white.  I then put the tasting notes field on top of it, with a clear background color, and, well, it looked pretty good:

![Details Screen](/images/wine_brain_new_wine_details.jpg)

I then implemented some <code>UITextViewDelegate</code> methods to give the apperance of placeholder text:

{% highlight objc %}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:DEFAULT_TASTING_NOTES_TEXT]) {
        textView.text = @"";
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text length] == 0) {
        textView.text = DEFAULT_TASTING_NOTES_TEXT;
    }
}
{% endhighlight %}

I considered using some third-party controls that mimic this behavior, but didn't want to get side-tracked adding new frameworks to my app at this point.

## User Testing

Once I had this, I handed my phone to Amy for some more user testing; She brought up a few obvious things that I had completely internalized and begun ignoring:

* Clicking "Save" on the details screen brought you back to the "new wine" screen, instead of just saving and bringing you back to the top.  A minor but obvious annoyance.
* She kept tapping on the "Choose Varietal" text field, thinking that would bring up the varietal chooser, instead of clicking the much smaller blue "disclosure" button
* She was a bit sad that the wines we had entered in the app would not be available on our shared Google Spreadsheet

To smooth the navigation after saving, I used a stock feature of the <code>UINavigationController</code> to "pop" more than once up the chain.  Since my design of the details screen used Apple's delegate pattern (essentially, the "add new wine" view controller was the delegate to the details view's lifecycle; when you click "Save" on the detail view, it triggers a callback in the "add new wine" view controller; the perfect place to save before the detail view controller popped back two screens).

The problem with the "Choose Varietal" control had bugged me, too, but I got used to it and didn't think about it.  The solution was very simple, though hacky.  I placed a clear button on top of the field the exact size of the field and had it trigger the same action as the blue disclosure button.  Problem solved.

As to maintaining the list up on Google Docs, I think I may need to implement this sooner rather than later; I think it's important to be able to get your data out of an application, and Google Docs is a reasonably user-friendly way to do it (as opposed to emailing some CSV file).  

## Other Random Bits

I still didn't get around to setting up iCuke for testing; I really should because I don't know what missing <code>retain</code> calls might be lurking.  I also finally created an icon, using a picture I took in Napa.  Not sure I like it, but it beats the white blob:

![Icon](/images/wine_brain_icon.png)

(Taken from [my original][iconoriginal]).

Finally, the app no longer starts up on the actual device.  A seemingly serious problem that I assume would be remedied by a re-install from scratch, however I have a few wines that I've added and don't particularly wanted to lose them.  Not sure how I could gain access to the SQL database to get them out, but I'm currently downloading the 4.0.1 update for my phone and the 2+ GB SDK update (!).

_As a followup, I had to re-install the application from scratch, though I was able to access the SQLite database from an iTunes backup.  I *really* need to implement a quicker backup/export mechanism..._

[part1]: /blog/2010/06/23/iphone-app-part-1.html
[part2]: /blog/2010/06/27/iphone-app-part-2.html
[part3]: /blog/2010/06/29/iphone-app-part-3.html
[part4]: /blog/2010/07/08/iphone-app-part-4.html
[iconoriginal]: http://www.flickr.com/photos/davetron5000/3805675435/
