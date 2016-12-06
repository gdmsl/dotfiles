--
-- IMAPFILTER config filehttps://github.com/wichtounet/dotfiles
--
-- Many things taken from https://github.com/wichtounet/dotfiles
--

function main()
    local account = IMAP {
        server = 'imap.gmail.com',
        username = 'guido.masella@gmail.com',
        password = get_imap_password(),
        ssl = 'tls1',
    }

    -- Make sure the account is configured properly
    account.INBOX:check_status()
    account['[Gmail]/Trash']:check_status()
    account['[Gmail]/Spam']:check_status()

    -- Get all mail from INBOX
    mails = account.INBOX:select_all()

    -- Move mailing lists from INBOX to correct folders
    move_mailing_lists(account, mails)

    -- Delete some trash
    -- delete_mail_from(account, mails, "enews@rockabilia.com");
    -- delete_mail_if_subject_contains(account, mails, "[CSSeminars] ");

    -- Get all mail from trash
    mails = account['[Gmail]/Trash']:select_all()

    -- Move mailing lists from trash to correct folders
    move_mailing_lists(account, mails)

    -- Get all mail from spam
    mails = account['[Gmail]/Spam']:select_all()

    -- Move mailing lists from spam to correct folders
    move_mailing_lists(account, mails)

    -- move_if_from_contains(account, mails, "edarling.ch", "INBOX")
end

function move_mailing_lists(account, mails)
    -- arch linux mailing lists
    move_if_subject_contains(account, mails, "[arch-general]", "ml/arch-general")
    move_if_subject_contains(account, mails, "[arch-security]", "ml/arch-security")
    move_if_subject_contains(account, mails, "[arch-announce]", "ml/arch-announce")
end

function move_if_subject_contains(account, mails, subject, mailbox)
    filtered = mails:contain_subject(subject)
    filtered:move_messages(account[mailbox]);
end

function move_if_to_contains(account, mails, to, mailbox)
    filtered = mails:contain_to(to)
    filtered:move_messages(account[mailbox]);
end

function move_if_from_contains(account, mails, from, mailbox)
    filtered = mails:contain_from(from)
    filtered:move_messages(account[mailbox]);
end

function delete_mail_from(account, mails, from)
    filtered = mails:contain_from(from)
    filtered:delete_messages()
end

function delete_mail_if_subject_contains(account, mails, subject)
    filtered = mails:contain_subject(subject)
    filtered:delete_messages()
end

-- Utility function to get IMAP password from file
function get_imap_password()
	local cmd = io.popen('gpg --no-tty --use-agent -q -d ~/usr/documents/id/msmtp-gmail.gpg', 'r')
	local out = cmd:read('*a')
	local pass = string.gsub(out, '[\n\r]+', '')
    return pass;
end

main()

