--
-- IMAPFILTER config filehttps://github.com/wichtounet/dotfiles
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
    -- Make sure the account is configured properly
    uds_account.INBOX:check_status()
    uds_account['INBOX/Trash']:check_status()

    -- Make sure the account is configured properly
    account.INBOX:check_status()
    account['[Gmail]/Trash']:check_status()
    account['[Gmail]/Spam']:check_status()

    -- Move mailing lists from INBOX to correct folders
    print("Moving Mailing Lists from INBOX")
    move_mailing_lists(account, "INBOX")
    move_mailing_lists_uds(uds_account, "INBOX")

    -- Move mailing lists from spam to correct folders
    print("Moving Mailing Lists from Spam")
    move_mailing_lists(account, "[Gmail]/Spam")

    -- Move mailing lists from trash to correct folders
    print("Moving Mailing Lists from Trash")
    move_mailing_lists(account, "[Gmail]/Trash")

    -- Move recurring bills to their folder
    print("Moving recurring bills to their folder")
    move_if_subject(account, "INBOX", "Facture du mobile", "finances/bills/recurring")
    move_if_subject(account, "[Gmail]/Trash", "Facture du mobile", "finances/bills/recurring")
    move_if_subject(account, "[Gmail]/Spam", "Facture du mobile", "finances/bills/recurring")
    move_if_subject(account, "INBOX", "Ricevuta del tuo pagamento a Netflix", "finances/bills/recurring")
    move_if_subject(account, "[Gmail]/Trash", "Ricevuta del tuo pagamento a Netflix", "finances/bills/recurring")
    move_if_subject(account, "[Gmail]/Spam", "Ricevuta del tuo pagamento a Netflix", "finances/bills/recurring")

    -- Delete steam wishlist mails older than 8 days
    print("Moving Steam Sales notifications older than 8 days to Trash")
    move_if_from_subject_older(account, "INBOX", "An item on your Steam wishlist is on sale!", "noreply@steampowered.com", 8, "[Gmail]/Trash")

    -- Move older calendar items
    print("Removing calendar messages older than 30 days.")
    move_if_from_older(account, "INBOX", "calendar-notification@google.com", 30, "[Gmail]/Trash")

    -- Moving conferences/seminar messages to the trash
    print("Removing event messages older than 5 days.")
    move_if_subject_older(uds_account, "INBOX", "Séminaire", 5, "Trash")
    move_if_subject_older(uds_account, "INBOX", "Conférence", 5, "Trash")
    move_if_subject_older(uds_account, "INBOX", "SEMINAIRE", 5, "Trash")
    move_if_subject_older(uds_account, "ml/isis", "Séminaire", 5, "Trash")
    move_if_subject_older(uds_account, "ml/isis", "Conférence", 5, "Trash")
    move_if_subject_older(uds_account, "ml/isis", "SEMINAIRE", 5, "Trash")
    move_if_subject_older(uds_account, "ml/chimie", "Séminaire", 5, "Trash")
    move_if_subject_older(uds_account, "ml/chimie", "Conférence", 5, "Trash")
    move_if_subject_older(uds_account, "ml/chimie", "SEMINAIRE", 5, "Trash")

    -- Cleanup of older mails
    print("Cleaning up older mails")
    move_if_older(account, "INBOX", 60, "cleanup")
    move_if_older(uds_account, "INBOX", 60, "cleanup")

    -- Cleaning older slurm mails
    move_if_older(account, "work/udshpc", 5, "[Gmail]/Trash")

end

function move_mailing_lists(account, mailbox)
    -- arch linux mailing lists
    move_if_subject(account, mailbox, "[arch-general]", "ml/arch-general")
    move_if_subject(account, mailbox, "[arch-security]", "ml/arch-security")
    move_if_subject(account, mailbox, "[ASA-", "ml/arch-security")
    move_if_subject(account, mailbox, "[arch-announce]", "ml/arch-announce")

    -- studentifisica2004 mailing lists
    move_if_subject(account, mailbox, "[Studentifisica2004]", "ml/studentifisica2004")

    -- fedora-classroom
    move_if_subject(account, mailbox, "[fedora-classroom]", "ml/fedora-classroom")

    -- github
    move_if_from(account, mailbox, "notifications@github.com", "ml/github")
end

function move_mailing_lists_uds(account, mailbox)
    move_if_subject(account, mailbox, "[unistra-personnels]", "ml/unistra-personnels")
    move_if_subject(account, mailbox, "[unistra-personnels-offre-formation-continue]", "ml/formation-continue")
    move_if_subject(account, mailbox, "[unistra-personnel-infos-syndicats]", "ml/infos-syndicats")
    move_if_to(account, mailbox, "isis@unistra.fr", "ml/isis")
    move_if_to(account, mailbox, "chimie@unistra.fr", "ml/chimie")
    move_if_to(account, mailbox, "ipcms1@unistra.fr", "ml/chimie")
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

-- Utility function to get IMAP password from file
function get_imap_password(filename)
	local cmd = io.popen('gpg --no-tty --use-agent -q -d ~/usr/documents/id/' .. filename, 'r')
	local out = cmd:read('*a')
	local pass = string.gsub(out, '[\n\r]+', '')
    return pass;
end

main()

