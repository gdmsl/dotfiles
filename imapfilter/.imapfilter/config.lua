--
-- IMAPFILTER config file
--
-- Many things taken from https://github.com/wichtounet/dotfiles
--

function main()
    local account = IMAP {
        server = 'imap.gmail.com',
        username = 'guido.masella@gmail.com',
        password = get_imap_password('mail-gmail.gpg'),
        ssl = 'tls1',
    }

    local uds_account = IMAP {
        server = 'mailserver.u-strasbg.fr',
        username = 'masella',
        password = get_imap_password('mail-uds.gpg'),
        ssl = 'ssl23',
    }

    local udsetu_account = IMAP {
        server = 'mailserver.u-strasbg.fr',
        username = 'gmasella',
        password = get_imap_password('mail-uds-etu.gpg'),
        ssl = 'ssl23',
    }

    -- Make sure that the uds accounts are configured properly
    uds_account.INBOX:check_status()
    uds_account['Sent']:check_status()
    uds_account['Trash']:check_status()

    udsetu_account.INBOX:check_status()
    udsetu_account['Sent']:check_status()
    udsetu_account['Trash']:check_status()

    -- Make sure the gmail account is configured properly
    account.INBOX:check_status()
    account['[Gmail]/Sent Mail']:check_status()
    account['[Gmail]/Trash']:check_status()
    account['[Gmail]/Spam']:check_status()

    -- Move emails to gmail
    print("Moving conversations to GMail")
    move_between_accounts(uds_account['INBOX'], account['mailaccounts/uds'], 10)
    move_between_accounts(udsetu_account['INBOX'], account['mailaccounts/uds-etu'], 10)
    move_between_accounts(uds_account['Sent'], account['[Gmail]/Sent Mail'], 10)
    move_between_accounts(udsetu_account['Sent'], account['[Gmail]/Sent Mail'], 10)

    -- Move mailing lists
    print("Moving mailing lists")
    move_mailing_lists(account, "INBOX")

    -- Move recurring bills to their folder
    print("Moving recurring bills to their folder")
    move_if_subject(account, "INBOX", "Facture du mobile", "finances/bills")
    move_if_subject(account, "[Gmail]/Trash", "Facture du mobile", "finances/bills")
    move_if_subject(account, "[Gmail]/Spam", "Facture du mobile", "finances/bills")

    -- Delete older amazon expedition emails
    print("Moving older amazon expedition emails")
    move_if_subject_older(account, "INBOX", "a été expeditée.", 30, "[Gmail]/Trash")
    move_if_subject_older(account, "INBOX", "è stato spedito.", 30, "[Gmail]/Trash")

    -- Delete steam wishlist mails older than 8 days
    print("Moving Steam Sales notifications older than 4 days to Trash")
    move_if_from_subject_older(account, "INBOX", "An item on your Steam wishlist is on sale!", "noreply@steampowered.com", 4, "[Gmail]/Trash")

    -- Move older calendar items
    print("Removing calendar messages older than 5 days.")
    move_if_from_older(account, "INBOX", "calendar-notification@google.com", 5, "[Gmail]/Trash")

    -- Cleanup of older mails
    print("Cleaning up older mails")
    move_if_older(account, "INBOX", 60, "cleanup")

    -- Cleaning older slurm mails
    move_if_older(account, "clusters/udshpc/jobs", 5, "[Gmail]/Trash")
end

function move_mailing_lists(account, mailbox)
    -- arch linux mailing lists
    move_if_subject(account, mailbox, "[arch-general]", "lists/arch-general")
    move_if_subject(account, mailbox, "[arch-security]", "lists/arch-security")
    move_if_subject(account, mailbox, "[ASA-", "lists/arch-security")
    move_if_subject(account, mailbox, "[arch-announce]", "lists/arch-announce")

    -- studentifisica2004 mailing lists
    move_if_subject(account, mailbox, "[Studentifisica2004]", "lists/studentifisica2004")

    -- github
    move_if_from(account, mailbox, "notifications@github.com", "lists/github-issues")

    -- university stuff
    move_if_to(account, mailbox, "isis@unistra.fr", "lists/isis")
    move_if_to(account, mailbox, "chimie@unistra.fr", "lists/chimie")
end

function move_if_subject(account, mailbox, subject, tomailbox)
    filtered = account[mailbox]:contain_subject(subject)
    filtered:move_messages(account[tomailbox]);
end

function move_if_to(account, mailbox, to, tomailbox)
    filtered = account[mailbox]:contain_to(to)
    filtered:move_messages(account[tomailbox]);
end

function move_if_from(account, mailbox, from, tomailbox)
    filtered = account[mailbox]:contain_from(from)
    filtered:move_messages(account[tomailbox]);
end

function move_if_match_from(account, mailbox, from, tomailbox)
    filtered = account[mailbox]:match_from(from)
    filtered:move_messages(account[tomailbox]);
end

function delete_if_from(account, mailbox, from)
    filtered = account[mailbox]:contain_from(from)
    filtered:delete_messages()
end

function delete_if_subject(account, mailbox, subject)
    filtered = account[mailbox]:contain_subject(subject)
    filtered:delete_messages()
end

function move_if_from_subject_older(account, mailbox, from, subject, olderthan, tomailbox)
    mails = account[mailbox]:select_all()
    filtered = account[mailbox]:contain_subject(subject) *
        account[mailbox]:contain_from(from) *
        account[mailbox]:is_older(olderthan)
    filtered:move_messages(account[tomailbox])
end

function move_if_subject_older(account, mailbox,subject, olderthan, tomailbox)
    mails = account[mailbox]:select_all()
    filtered = account[mailbox]:contain_subject(subject) *
        account[mailbox]:is_older(olderthan)
    filtered:move_messages(account[tomailbox])
end

function move_if_from_older(account, mailbox, from, olderthan, tomailbox)
    filtered = account[mailbox]:contain_from(from) *
        account[mailbox]:is_older(olderthan)
    filtered:move_messages(account[tomailbox])
end

function move_if_older(account, mailbox, olderthan, tomailbox)
    filtered = account[mailbox]:is_older(olderthan)
    filtered:move_messages(account[tomailbox])
end

-- Move from accounts
function move_between_accounts(mailboxfrom, mailboxto, olderthan)
    filtered = mailboxfrom:is_older(olderthan)
    filtered:move_messages(mailboxto)
end

-- Utility function to get IMAP password from file
function get_imap_password(filename)
	local cmd = io.popen('gpg --no-tty --use-agent -q -d ~/Documents/Identity/' .. filename, 'r')
	local out = cmd:read('*a')
	local pass = string.gsub(out, '[\n\r]+', '')
    return pass;
end

main()

