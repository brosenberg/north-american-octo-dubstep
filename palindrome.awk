#!/usr/bin/awk -f
{
    gsub(/[^a-zA-Z0-9]/, "")
    $0=toupper($0)
    half_length=(length)/2
    length_mod=1

    if (int(half_length+0.5) != int(half_length)) {
        length_mod=2
        half_length-=.5
    }

    left=substr($0, 0, half_length)
    right=substr($0, half_length+length_mod, half_length)

    for (i=length(right); i>0; i--)
        right_rev=right_rev substr(right, i, 1)

    if (left == right_rev) {
        print "Palindrome"
    } else {
        print "Not a palindrome"
    }
}
